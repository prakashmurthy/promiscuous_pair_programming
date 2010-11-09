shared_examples_for "a location-based model" do
  # TODO: This may not be correct...
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
  it "does not geolocate the location if :enable_geolocation is set to false" do
    subject.enable_geolocation = false
    subject.should_not_receive(:do_geolocation)
    subject.save!
  end
  
  it "does not geolocate the location if :enable_geolocation is set to true, but Location.geolocation_disabled is set to false" do
    Location.stub(:geolocation_disabled) { false }
    subject.enable_geolocation = false
    subject.should_not_receive(:do_geolocation)
    subject.save!
  end
end

shared_examples_for "a location-based model: create callbacks" do
  it_behaves_like "a location-based model: create/update callbacks"
  
  it "geolocates the raw_location if :enable_geolocation is set to true, making a new location record" do
    subject.raw_location = "Boulder, CO"
    geo = double("geo")
    geo.stub(:success) { true }
    geo.stub(:lat) { "93.393893" }
    geo.stub(:lng) { "-108.390894" }
    # ...
    # TODO: Need to use a proxy here... may have to use RR
    subject.enable_geolocation = true
    Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).with("Boulder, CO") { geo }
    subject.save!
    Location.count.should == 1
    subject.location.lat.should == 93.393893
    subject.location.lng.should == -108.390894
    # ...
  end
end

shared_examples_for "a location-based model: update callbacks" do
  it_behaves_like "a location-based model: create/update callbacks"
  
  it "geolocates the raw_location if :enable_geolocation is set to true, re-saving the location record" do
    subject.raw_location = "Boulder, CO"
    geo = double("geo")
    geo.stub(:success) { true }
    geo.stub(:lat) { "93.393893" }
    geo.stub(:lng) { "-108.390894" }
    # ...
    # TODO: Need to use a proxy here... may have to use RR
    subject.enable_geolocation = true
    Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).with("Boulder, CO") { geo }
    subject.save!
    Location.count.should == 1
    subject.location.lat.should == 93.393893
    subject.location.lng.should == -108.390894
    # ...
  end
end