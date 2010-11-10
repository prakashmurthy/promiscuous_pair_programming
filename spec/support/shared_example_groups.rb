shared_examples_for "a location-based model" do
  it "when generating error messages, aliases raw_location to location" do
    described_class.stub(:geolocation_disabled?) { false }
    subject.raw_location = nil
    subject.enable_geolocation = true
    subject.valid?
    subject.errors.full_messages.should include("Location can't be blank")
  end
end

shared_examples_for "a location-based model: validations" do
  it "requires raw_location to be filled in if :enable_geolocation is set to true" do
    described_class.stub(:geolocation_disabled?) { false }
    subject.enable_geolocation = true
    subject.raw_location = nil
    subject.should_not be_valid
  end

  it "does not require raw_location to be filled in if :enable_geolocation is set to false" do
    described_class.stub(:geolocation_disabled?) { false }
    subject.enable_geolocation = false
    subject.raw_location = nil
    subject.should be_valid
  end
  
  it "does not require raw_location to be filled in if :enable_geolocation is set to true, but #{described_class}.geolocation_disabled is also set to true" do
    described_class.stub(:geolocation_disabled?) { true }
    subject.enable_geolocation = true
    subject.raw_location = nil
    subject.should be_valid
  end
  
  it "doesn't crash if geolocation is disabled and location_id is not filled in" do
    subject.enable_geolocation = false
    subject.location_id = nil
    expect { subject.save }.to_not raise_error(PGError)
  end
end

shared_examples_for "a location-based model: create/update callbacks" do
  context "when :enable_geolocation is set to true" do
    before do
      subject.enable_geolocation = true
    end
    
    it "gives the raw_location to Geokit" do
      described_class.stub(:geolocation_disabled?) { false }
      subject.raw_location = "Boulder, CO"
      geo = double("geo")
      stubs = PPP::ModelMixins::Geolocation::GEOLOC_ATTRIBUTES.inject(:success? => true) {|h,a| h[a] = "1"; h }
      stubs.each {|k,v| geo.stub(k).and_return(v) }
      Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).with("Boulder, CO") { geo }
      subject.save!
    end
    
    it "bails if the location could not be geolocated" do
      described_class.stub(:geolocation_disabled?) { false }
      described_class.stub(:fetch_location_info) { nil }
      subject.raw_location = "salkj"
      subject.save.should == false
      subject.errors.full_messages.should include(
        "Sorry, but we couldn't find the location you entered. " + 
        "You might try entering something simpler, such as a zip code."
      )
    end
    
    it "bails if the geocoded response doesn't have enough data to make a valid location" do
      described_class.stub(:geolocation_disabled?) { false }
      described_class.stub(:fetch_location_info) do
        {
          :raw_location => "salkj",
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
      subject.raw_location = "salkj"
      subject.save.should == false
      subject.errors.full_messages.should include(
        "Sorry, but we couldn't find the location you entered. " + 
        "You might try entering something simpler, such as a zip code."
      )
    end
    
    it "does not geolocate the location if #{described_class}.geolocation_disabled is also set to true" do
      described_class.stub(:geolocation_disabled?) { true }
      subject.should_not_receive(:do_geolocation)
      subject.save!
    end
  end
  
  context "when :enable_geolocation is set to false" do
    before do
      subject.enable_geolocation = false
    end
    
    it "does not geolocate the location" do
      described_class.stub(:geolocation_disabled?) { false }
      subject.should_not_receive(:do_geolocation)
      subject.save!
    end
  end
end

shared_examples_for "a location-based model: create callbacks" do
  subject do
    if described_class == PairingSession
      Factory.build(:pairing_session, :owner => Factory.create(:user), :location => nil)
    else
      Factory.build(:user, :location => nil)
    end
  end
  
  it_behaves_like "a location-based model: create/update callbacks"
  
  context "when :enable_geolocation is set to true" do
    before do
      subject.enable_geolocation = true
    end
    
    it "makes a new location record using the attributes in the GeoLoc object returned from Geokit" do
      described_class.stub(:geolocation_disabled?) { false }
      described_class.stub(:fetch_location_info) do
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
  
  context "if :enable_geolocation is set to true" do
    before do
      subject.enable_geolocation = true
    end
    
    it "updates the existing location record using the attributes in the GeoLoc object returned from Geokit" do
      described_class.stub(:geolocation_disabled?) { false }
      described_class.stub(:fetch_location_info) do
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