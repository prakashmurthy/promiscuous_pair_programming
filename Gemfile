source 'http://rubygems.org'

gem 'rails', '3.0.1'
gem 'pg', '0.9.0'
gem 'devise', '1.1.3'
gem 'omniauth', '0.1.5'
gem "escape_utils", '0.1.9'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :test, :development do
  gem 'heroku'
  gem 'rails3-generators'
  gem 'rspec-rails'
  gem 'cucumber-rails'
  gem 'pickle'
  gem 'capybara'
  gem 'launchy' # So you can do Then show me the page
  gem 'thin' # this will speed up your cucumber @javascript tests by a lot
  gem 'factory_girl_rails', :git => 'git://github.com/msgehard/factory_girl_rails.git'
end