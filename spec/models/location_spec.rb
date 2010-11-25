require File.expand_path('../../spec_helper', __FILE__)

describe Location do
  let(:location) { Factory.build(:location) }
  
  describe '.geocode' do
    it "returns a canned return value if Location.geocoding_disabled is set to true" do
      Location.stub(:geocoding_disabled?) { true }
      Location.geocode("some location").should == {
        "raw_location" => "1521 Pearl St, Boulder, CO, 80302",
        "lat" => 40.0189782,
        "lng" => -105.2753118,
        "street_address" => "1521 Pearl St",
        "city" => "Boulder",
        "province" => "Boulder",
        "district" => nil,
        "state" => "CO",
        "zip" => "80302",
        "country" => "USA",
        "country_code" => "US",
        "accuracy" => 8,
        "precision" => "address",
        "suggested_bounds" => "40.0158306,-105.2784594,40.0221258,-105.2721642",
        "provider" => "google"
      }
    end
    it "geocodes the given string using Geokit, extracts data from the GeoLoc object, and returns it" do
      Location.stub(:geocoding_disabled?) { false }
      (geo = Object.new).stub(
        :success? => true,
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
      Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).with("some location") { geo }
      data = Location.geocode("some location")
      data.should == {
        :raw_location => "some location",
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
    it "dies if geocoding was unsuccessful" do
      Location.stub(:geocoding_disabled?) { false }
      (geo = Object.new).stub(:success?) { false }
      Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).with("some location") { geo }
      Location.geocode("some location").should == nil
    end
  end
  
  context "validations" do
    it "requires raw_location to be filled in" do
      location.raw_location = nil
      location.should_not be_valid
    end
    
    it "requires lat to be filled in" do
      location.lat = nil
      location.should_not be_valid
    end
    
    it "requires lng to be filled in" do
      location.lng = nil
      location.should_not be_valid
    end
    
    it "requires city to be filled in" do
      location.city = nil
      location.should_not be_valid
    end
    
    it "requires province to be filled in" do
      location.province = nil
      location.should_not be_valid
    end
    
    it "requires state to be filled in" do
      location.state = nil
      location.should_not be_valid
    end
    
    #it "requires zip to be filled in" do
    #  location.zip = nil
    #  location.should_not be_valid
    #end
    
    it "requires country to be filled in" do
      location.country = nil
      location.should_not be_valid
    end
    
    it "requires country_code to be filled in" do
      location.country_code = nil
      location.should_not be_valid
    end
    
    it "requires accuracy to be filled in" do
      location.accuracy = nil
      location.should_not be_valid
    end
    
    it "fails validation if the accuracy is 0" do
      location.accuracy = 0
      location.should_not be_valid
    end
    
    it "requires precision to be filled in" do
      location.precision = nil
      location.should_not be_valid
    end
    
    it "fails validation if the precision is 'unknown'" do
      location.precision = "unknown"
      location.should_not be_valid
    end
    
    it "requires suggested_bounds to be filled in" do
      location.suggested_bounds = nil
      location.should_not be_valid
    end
    
    it "requires provider to be filled in" do
      location.provider = nil
      location.should_not be_valid
    end
  end 
  
  describe '#coordinates' do
    it "should return a stringified version of the latitude and longitude" do
      location.lat = "39.39492"
      location.lng = "-108.23490"
      location.coordinates.should == "39.39492, -108.2349"
    end
  end
end

# == Schema Information
#
# Table name: locations
#
#  id               :integer         not null, primary key
#  raw_location     :string(255)     not null
#  lat              :float           not null
#  lng              :float           not null
#  street_address   :string(255)
#  city             :string(255)     not null
#  province         :string(255)     not null
#  district         :string(255)
#  state            :string(255)     not null
#  zip              :string(255)
#  country          :string(255)     not null
#  country_code     :string(255)     not null
#  accuracy         :integer         not null
#  precision        :string(255)     not null
#  suggested_bounds :string(255)     not null
#  provider         :string(255)     not null
#  created_at       :datetime
#  updated_at       :datetime
#
