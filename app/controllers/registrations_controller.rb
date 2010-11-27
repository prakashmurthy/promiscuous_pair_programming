class RegistrationsController < Devise::RegistrationsController
private
  # Override existing method in Devise to ensure location is geocoded
  def build_resource(*args)
    super.tap do |resource|
      #resource.enable_geocoding = true
    end
  end
  
  # Override existing method in Devise to ensure location is geocoded
  def authenticate_scope!
    super.tap do |resource|
      #resource.enable_geocoding = true
    end
  end
end
