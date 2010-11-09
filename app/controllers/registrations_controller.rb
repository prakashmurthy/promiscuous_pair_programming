class RegistrationsController < Devise::RegistrationsController
private
  # Doo dee doo... override existing method in Devise to ensure location is geolocated
  #def build_resource(*args)
  #  super.tap do |resource|
  #    #(resource.location || resource.build_location).enable_geolocation = true
  #    resource.build_location unless resource.location
  #  end
  #end
end