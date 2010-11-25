module PPP
  module ControllerMixins
    module Geolocation
      extend ActiveSupport::Concern
      
      included do
        alias :detect_current_location :current_location
        helper_method :current_location, :current_radius
        
        #before_filter :detect_current_location, :if => :user_signed_in?
      end
      
    private
      def current_location
        return @_current_location if @_current_location
        self.current_location = session[:current_location] || current_ip
        @_current_location
      end
      
      def current_location=(location_string_or_data)
        unless Hash === location_string_or_data
          location_string_or_data = session[:current_location] = Location.geocode(location_string_or_data)
        end
        @_current_location = Location.new(location_string_or_data)
      end

      def current_ip
        remote_ip = request.remote_ip
        if remote_ip == "127.0.0.1"
          # This should resolve to Boulder, CO
          remote_ip = "161.97.1.1"
        end
        logger.debug "Remote IP: #{remote_ip}"
        remote_ip
      end
      
      def current_radius
        return @_current_radius if @_current_radius
        self.current_radius = session[:current_radius] || 10
        @_current_radius
      end
      
      def current_radius=(radius)
        @_current_radius = session[:current_radius] = radius
      end
    end
  end
end