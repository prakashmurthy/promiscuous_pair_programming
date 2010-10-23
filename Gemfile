source 'http://rubygems.org'

gem 'rails', '3.0.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3-ruby', :require => 'sqlite3'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end


group :test do
  gem 'rspec-rails'
  gem 'cucumber-rails'
  # use capybara instead of webrat
  # run rails g cucumber:install --capybara
  # to generate cucumber config for capybara
  gem 'capybara'
  gem 'launchy' # So you can do Then show me the page
  gem 'thin' # this will speed up your cucumber @javascript tests by a lot
#  gem "factory_girl"
  gem 'factory_girl_rails', :git => 'git://github.com/msgehard/factory_girl_rails.git'
end