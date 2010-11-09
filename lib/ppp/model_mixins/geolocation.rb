module PPP
  module ModelMixins
    module Geolocation
      GEOLOC_ATTRIBUTES = [
        :lat, :lng, :street_address, :city, :province, :district, :state, :zip, :country,
        :country_code, :accuracy, :precision, :suggested_bounds, :provider
      ]
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def is_geolocatable
          singleton_class.class_eval do
            attr_accessor :geolocation_disabled
            alias_method :geolocation_disabled?, :geolocation_disabled
          end

          attr_accessor :enable_geolocation
          #def enable_geolocation=(value); @enable_geolocation = (value.to_s == "true"); end
          alias_method :enable_geolocation?, :enable_geolocation
          
          attr_accessor :raw_location
          validates :location, :presence => true, :if => :enable_geolocation?

          before_save :do_geolocation, :if => :do_geolocation?
          
          belongs_to :location
          #accepts_nested_attributes_for :location
          #attr_accessible :location_attributes
          # Import methods that allow us to search by radius, etc.
          # Additionally, locations are actually stored in a separate table, but the :through
          # allows us to call User.find_within(50, ...) by reaching into the location association.
          acts_as_mappable :through => :location
        end
      end
      
      def read_attribute_for_validation(name)
        name.to_s == "location" ? super("raw_location") : super(name)
      end

    private
      def do_geolocation
        geo = Geokit::Geocoders::MultiGeocoder.geocode(raw_location)
        if geo.success?
          location = new_record? ? self.build_location : self.location
          for attr in GEOLOC_ATTRIBUTES
            # TODO: Test suggested_bounds
            location.send("#{attr}=", geo.send(attr))
          end
        else
          self.errors.add_to_base("The location you entered couldn't be geolocated for some reason. You might try enter something simpler such as a zip code.")
        end
      end

      def do_geolocation?
        !self.class.geolocation_disabled? && enable_geolocation?
      end
    end
  end
end