shared_examples_for "a location-based model" do
  it "when generating error messages, aliases raw_location to location" do
    subject.raw_location = nil
    subject.enable_geolocation = true
    subject.valid?
    subject.errors.full_messages.should include("Location can't be blank")
  end
end

shared_examples_for "a location-based model: validations" do
  it "requires raw_location to be filled in if :enable_geolocation is set to true" do
    subject.enable_geolocation = true
    subject.raw_location = nil
    subject.should_not be_valid
  end

  it "does not require raw_location to be filled in if :enable_geolocation is set to false" do
    subject.enable_geolocation = false
    subject.raw_location = nil
    subject.should be_valid
  end
end

shared_examples_for "a location-based model: create/update callbacks" do
  it "if :enable_geolocation is set to true: gives the raw_location to Geokit" do
    described_class.stub(:geolocation_disabled?) { false }
    subject.raw_location = "Boulder, CO"
    geo = double("geo")
    geo.stub(
      :success? => true,
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
    )
    Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).with("Boulder, CO") { geo }
    subject.enable_geolocation = true
    subject.save!
  end
  
  it "does not geolocate the location if :enable_geolocation is set to false" do
    described_class.stub(:geolocation_disabled?) { false }
    subject.enable_geolocation = false
    subject.should_not_receive(:do_geolocation)
    subject.save!
  end
  
  it "does not geolocate the location if :enable_geolocation is set to true, but Location.geolocation_disabled is set to true" do
    Location.stub(:geolocation_disabled) { true }
    subject.enable_geolocation = false
    subject.should_not_receive(:do_geolocation)
    subject.save!
  end
end

shared_examples_for "a location-based model: create callbacks" do
  it "if :enable_geolocation is set to true: makes a new location record using the attributes in the GeoLoc object returned from Geokit" do
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
    subject.enable_geolocation = true
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

shared_examples_for "a location-based model: update callbacks" do
  it "if :enable_geolocation is set to true: updates the existing location record using the attributes in the GeoLoc object returned from Geokit" do
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
    subject.enable_geolocation = true
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