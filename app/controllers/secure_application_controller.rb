class SecureApplicationController < ApplicationController
  before_filter :authenticate_user!
end