class RegistrationsController < Devise::RegistrationsController
private
  # Override existing method in Devise to ensure location is geolocated
  def build_resource(*args)
    super.tap do |resource|
      resource.enable_geolocation = true
    end
  end
  
  # Override existing method in Devise to ensure location is geolocated
  def authenticate_scope!
    super.tap do |resource|
      resource.enable_geolocation = true
    end
  end
end
