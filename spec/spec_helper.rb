# This file is copied to spec/ when you run 'rails generate rspec:install'

begin
  require 'spork'
rescue LoadError => e
  require 'rubygems'
  require 'spork'
end

Spork.prefork do
  # Block routes from reloading, since this references models (such as User)
  # that we want to be able to reload
  Spork.trap_method(Rails::Application, :reload_routes!) if defined?(Rails)
  
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true
  end
end

Spork.each_run do
  # ...
end