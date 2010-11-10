# I know that nothing should be mocked in Cucumber, but this is a specific case,
# since we're making an external API call.

Given /^the location of the (?:new )?pairing session will be geolocated as "([^"]*)"$/ do |location|
  PairingSession.stub(:geolocation_disabled?) { false }
  PairingSession.stub(:fetch_location_info) {
    Factory.attributes_for(:location).merge(:raw_location => location)
  }
end

Given /^(?:my location|the location of the (?:new )user) will be geolocated as "([^"]*)"$/ do |location|
  User.stub(:geolocation_disabled?) { false }
  User.stub(:fetch_location_info) {
    Factory.attributes_for(:location).merge(:raw_location => location)
  }
end