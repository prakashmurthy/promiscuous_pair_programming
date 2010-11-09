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
          attr_accessible :raw_location if accessible_attributes.any?

          before_save :do_geolocation, :if => :do_geolocation?
          
          belongs_to :location, :autosave => true
          #accepts_nested_attributes_for :location
          #attr_accessible :location_attributes
          # Import methods that allow us to search by radius, etc.
          # Additionally, locations are actually stored in a separate table, but the :through
          # allows us to call User.find_within(50, ...) by reaching into the location association.
          acts_as_mappable :through => :location
        end
        
        def fetch_location_info(raw_location)
          logger.debug "Geolocating #{raw_location}..."
          geo = Geokit::Geocoders::MultiGeocoder.geocode(raw_location)
          if geo.success?
            logger.debug "=> Got result:"
            logger.debug "#{geo}"
            attrs = {:raw_location => raw_location}
            return GEOLOC_ATTRIBUTES.inject(attrs) do |attrs, attr|
              # TODO: Test suggested_bounds
              attrs[attr] = geo.send(attr)
              attrs
            end
          else
            return nil
          end
        end
      end
      
      # Show "Location can't be blank" instead of "Raw location can't be blank"
      def read_attribute_for_validation(name)
        name.to_s == "location" ? super("raw_location") : super(name)
      end

    private
      def do_geolocation
        if attrs = self.class.fetch_location_info(raw_location)
          logger.debug "Got attributes:"
          logger.debug attrs.inspect
          location = new_record? ? self.build_location : self.location
          location.attributes = attrs
        else
          self.errors.add_to_base("The location you entered couldn't be geolocated for some reason. You might try enter something simpler such as a zip code.")
        end
      end

      def do_geolocation?
        (!self.class.geolocation_disabled? && enable_geolocation?).tap do |value|
          logger.debug "Geolocation enabled? #{value.inspect}"
        end
      end
    end
  end
end