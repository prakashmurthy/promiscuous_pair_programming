class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include PPP::ControllerMixins::Geolocation

  # Override Devise functionality on where to send the user
  # after they have been logged in
  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      pairing_sessions_path
    else
      super
    end
  end
end
