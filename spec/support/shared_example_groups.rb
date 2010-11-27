shared_examples_for "a location-based model" do
  it "aliases raw_location to location when generating error messages" do
    subject.stub(:do_geocoding?) { true }
    subject.raw_location = nil
    subject.enable_geocoding = true
    subject.valid?
    subject.errors.full_messages.should include("Location can't be blank")
  end
end

shared_examples_for "a location-based model: validations" do
  it "requires raw_location to be filled in if :enable_geocoding is set to true" do
    Location.stub(:geocoding_disabled?) { false }
    subject.enable_geocoding = true
    subject.raw_location = nil
    subject.should_not be_valid
  end

  it "does not require raw_location to be filled in if :enable_geocoding is set to false" do
    subject.enable_geocoding = false
    subject.raw_location = nil
    subject.should be_valid
  end
  
  it "does not require raw_location to be filled in if :enable_geocoding is set to true, but Location.geocoding_disabled is also set to true" do
    Location.stub(:geocoding_disabled?) { true }
    subject.enable_geocoding = true
    subject.raw_location = nil
    subject.should be_valid
  end
  
  it "doesn't crash if geocoding is disabled and location_id is not filled in" do
    subject.stub(:do_geocoding?) { false }
    subject.location_id = nil
    expect { subject.save }.to_not raise_error(PGError)
  end
end

shared_examples_for "a location-based model: create/update callbacks" do
  context "when :enable_geocoding is set to true" do
    before do
      Location.stub(:geocoding_disabled?) { false }
      subject.enable_geocoding = true
    end
    
    it "defers to Location.geocode in order to geocode the location" do
      subject.raw_location = "Boulder, CO"
      Location.should_receive(:geocode).with("Boulder, CO") { Factory.attributes_for(:location) }
      subject.save!
    end
    
    it "bails if the location could not be geolocated" do
      subject.raw_location = "Boulder, CO"
      Location.stub(:geocode) { nil }
      subject.save.should == false
      subject.errors.full_messages.should include(
        "Sorry, but we couldn't find the location you entered. " + 
        "You might try entering something simpler, such as a zip code."
      )
    end
    
    it "also bails if the geocoding data isn't enough to make a valid location" do
      Location.stub(:geocode) do
        {
          :raw_location => "some location",
          :lat => 40.0189782,
          :lng => -105.2753118,
          :street_address => nil,
          :city => nil,
          :province => nil,
          :district => nil,
          :state => nil,
          :zip => nil,
          :country => nil,
          :country_code => nil,
          :accuracy => 0,
          :precision => "unknown",
          :suggested_bounds => "40.0158306,-105.2784594,40.0221258,-105.2721642",
          :provider => "google"
        }
      end
      subject.raw_location = "some location"
      subject.save.should == false
      subject.errors.full_messages.should include(
        "Sorry, but we couldn't find the location you entered. " + 
        "You might try entering something simpler, such as a zip code."
      )
    end
    
    it "doesn't even hit the before_save if Location.geocoding_disabled is also set to true" do
      Location.stub(:geocoding_disabled?) { true }
      subject.should_not_receive(:do_geolocation)
      subject.save!
    end
  end
  
  context "when :enable_geocoding is set to false" do
    before do
      Location.stub(:geocoding_disabled?) { false }
      subject.enable_geocoding = false
    end
    
    it "doesn't even hit the before_save" do
      subject.should_not_receive(:do_geolocation)
      subject.save!
    end
  end
end

shared_examples_for "a location-based model: create callbacks" do
  # UGH this is a hack b/c associations in factories are being saved
  subject do
    if described_class == PairingSession
      Factory.build(:pairing_session, :owner => Factory.create(:user), :location => nil)
    else
      Factory.build(:user, :location => nil)
    end
  end
  
  it_behaves_like "a location-based model: create/update callbacks"
  
  context "when :enable_geocoding is set to true" do
    before do
      Location.stub(:geocoding_disabled?) { false }
      subject.enable_geocoding = true
    end
    
    it "makes a new location record using the attributes in the GeoLoc object returned from Geokit" do
      Location.stub(:geocode) do
        {
          :raw_location => "1521 Pearl St, Boulder, CO, 80302",
          :lat => 40.0189782,
          :lng => -105.2753118,
          :street_address => "1521 Pearl St",
          :city => "Boulder",
          :province => "Boulder",
          :district => nil,
          :state => "CO",
          :zip => "80302",
          :country => "USA",
          :country_code => "US",
          :accuracy => 8,
          :precision => "address",
          :suggested_bounds => "40.0158306,-105.2784594,40.0221258,-105.2721642",
          :provider => "google"
        }
      end
      subject.raw_location = "Boulder, CO"
      expect { subject.save! }.to change(Location, :count).by(1)
      loc = subject.location
      loc.raw_location.should == "1521 Pearl St, Boulder, CO, 80302"
      loc.lat.should == 40.0189782
      loc.lng.should == -105.2753118
      loc.street_address.should == "1521 Pearl St"
      loc.city.should == "Boulder"
      loc.province.should == "Boulder"
      loc.district.should == nil
      loc.state.should == "CO"
      loc.zip.should == "80302"
      loc.country.should == "USA"
      loc.country_code.should == "US"
      loc.accuracy.should == 8
      loc.precision.should == "address"
      loc.suggested_bounds.should == "40.0158306,-105.2784594,40.0221258,-105.2721642"
      loc.provider.should == "google"
    end
  end
end

shared_examples_for "a location-based model: update callbacks" do
  it_behaves_like "a location-based model: create/update callbacks"
  
  context "if :enable_geocoding is set to true" do
    before do
      Location.stub(:geocoding_disabled?) { false }
      subject.enable_geocoding = true
    end
    
    it "updates the existing location record using the attributes in the GeoLoc object returned from Geokit" do
      Location.stub(:geocode) do
        {
          :raw_location => "1521 Pearl St, Boulder, CO, 80302",
          :lat => 40.0189782,
          :lng => -105.2753118,
          :street_address => "1521 Pearl St",
          :city => "Boulder",
          :province => "Boulder",
          :district => nil,
          :state => "CO",
          :zip => "80302",
          :country => "USA",
          :country_code => "US",
          :accuracy => 8,
          :precision => "address",
          :suggested_bounds => "40.0158306,-105.2784594,40.0221258,-105.2721642",
          :provider => "google"
        }
      end
      subject.raw_location = "Boulder, CO"
      expect { subject.save! }.to_not change(Location, :count)
      loc = subject.location
      loc.raw_location.should == "1521 Pearl St, Boulder, CO, 80302"
      loc.lat.should == 40.0189782
      loc.lng.should == -105.2753118
      loc.street_address.should == "1521 Pearl St"
      loc.city.should == "Boulder"
      loc.province.should == "Boulder"
      loc.district.should == nil
      loc.state.should == "CO"
      loc.zip.should == "80302"
      loc.country.should == "USA"
      loc.country_code.should == "US"
      loc.accuracy.should == 8
      loc.precision.should == "address"
      loc.suggested_bounds.should == "40.0158306,-105.2784594,40.0221258,-105.2721642"
      loc.provider.should == "google"
    end
  end
end