class Forbidden403Exception < StandardError

end

class SecureApplicationController < ApplicationController
  before_filter :authenticate_user!

  rescue_from ::Forbidden403Exception, :with => :show_403_forbidden

  private

  def show_403_forbidden
    render :status => 403, :file => Rails.root.join("public", "403.html"), :layout => false
  end
end