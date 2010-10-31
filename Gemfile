source 'http://rubygems.org'

gem 'rails', '3.0.1'
gem 'pg', '0.9.0'
gem 'devise', '1.1.3'
gem 'omniauth', '0.1.5'
gem "escape_utils", '0.1.9'

group :development do
  gem 'rspec-rails'
  gem 'heroku'
  gem "mongrel", ">= 1.2.0.pre2" # use mongrel instead of webrick for development
end

group :test do
  gem 'rails3-generators'
  gem 'cucumber-rails'
  gem 'pickle'
  gem 'capybara'
  gem 'launchy' # So you can do Then show me the page
  gem 'thin' # this will speed up your cucumber @javascript tests by a lot
  gem 'factory_girl_rails', :git => 'git://github.com/msgehard/factory_girl_rails.git'
  gem 'database_cleaner'
  gem 'timecop'	
end