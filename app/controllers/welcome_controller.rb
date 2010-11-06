class WelcomeController < ApplicationController

  def index
    @pairing_sessions = PairingSession.available
  end

end
