class Location < ActiveRecord::Base
  GEOLOC_ATTRIBUTES = [
    :lat, :lng, :street_address, :city, :province, :district, :state, :zip, :country,
    :country_code, :accuracy, :precision, :suggested_bounds, :provider
  ]
  CANNED_LOCATION_DATA = {
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
  
  class NotFoundError < StandardError; end
  
  class << self
    attr_accessor :geocoding_disabled
    alias_method :geocoding_disabled?, :geocoding_disabled
  
    def geocode(location_string)
      if geocoding_disabled?
        logger.debug "Geolocation is disabled. Returning a canned location..."
        return CANNED_LOCATION_DATA
      else
        logger.debug "Geocoding #{location_string.inspect}..."
        geo = Geokit::Geocoders::MultiGeocoder.geocode(location_string)
        if geo.success?
          logger.debug "Got a match!"
          logger.debug geo.inspect
          hash = GEOLOC_ATTRIBUTES.inject({}) {|hash, attr| hash[attr] = geo.send(attr); hash }
          hash[:raw_location] = location_string
          return hash
        else
          # TODO: What's the best way to handle this?
          logger.debug "Ack, couldn't geolocate?!"
          #raise LocationNotFound, "Couldn't geocode #{location_string} for some reason!"
          return nil
        end
      end
    end
  end
  
  acts_as_mappable
  
  # Geocoding a city won't return a street address or zip code, so we can't require that
  ([:raw_location] + GEOLOC_ATTRIBUTES - [:street_address, :district, :zip]).each do |attr|
    validates attr, :presence => true
  end
  
  validate :accuracy_cannot_be_zero
  validate :precision_cannot_be_unknown
  
  def coordinates
    "#{lat}, #{lng}"
  end
  
private
  # The error messages here aren't that meaningful, but it doesn't matter since aren't using them anyway
  def accuracy_cannot_be_zero
    self.errors.add(:accuracy, "cannot be zero") if accuracy == 0
  end
  def precision_cannot_be_unknown
    self.errors.add(:precision, "cannot be unknown") if precision == "unknown"
  end
end# == Schema Information
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

