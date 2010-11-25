module PPP
  module ModelMixins
    module Geocoding
      extend ActiveSupport::Concern
      
      module ClassMethods
        def auto_geocode_location
          attr_accessor :enable_geocoding
          alias_method :enable_geocoding?, :enable_geocoding
          
          attr_accessor :raw_location
          validates :location, :presence => true, :if => :do_geocoding?
          attr_accessible :raw_location if accessible_attributes.any?

          before_save :do_geocoding, :if => :do_geocoding?
          
          # Import methods that allow us to search by radius, etc.
          # Additionally, locations are actually stored in a separate table, but the :through
          # allows us to call User.find_within(50, ...) by reaching into the location association.
          acts_as_mappable :through => :location
        end
      end
      
      module InstanceMethods
        # Show "Location can't be blank" instead of "Raw location can't be blank"
        def read_attribute_for_validation(name)
          name.to_s == "location" ? super("raw_location") : super(name)
        end

      private
        def do_geocoding
          if attrs = Location.geocode(raw_location)
            logger.debug "Got attributes:"
            logger.debug attrs.inspect
            location = self.location || Location.new
            location.attributes = attrs
            logger.debug "Location is this:"
            logger.debug location.inspect
            logger.debug "Saving location..."
            if location.save
              logger.debug "Cool! Looks like the location is valid."
              # just to be explicit
              self.location_id = location.id
              return true
            end
          end
          logger.debug "Whoops, the location wasn't valid!"
          self.errors.add(:base, "Sorry, but we couldn't find the location you entered. You might try entering something simpler, such as a zip code.")
          return false
        end
      end
      
      def do_geocoding?
        enable_geocoding? && !Location.geocoding_disabled?
      end
    end
  end
end