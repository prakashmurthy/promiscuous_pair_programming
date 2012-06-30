source 'http://rubygems.org'

gem 'rails', '3.0.3'
gem 'pg', '0.9.0'
gem 'devise', '1.1.3'
gem "escape_utils", '0.1.9'
gem "geokit-rails3", '0.1.2'
gem "meta_where", '0.9.9.2'

group :test, :development do
  if RUBY_VERSION < "1.9"
    gem 'ruby-debug'
  else
    gem 'ruby-debug19'
  end
  gem 'rspec-rails', '~> 2.3.0'
  gem 'rails3-generators', '~> 0.17.0'
  gem 'cucumber', '~> 0.10.0'
  gem 'cucumber-rails', '~> 0.3.2'
end

group :development do
  gem 'annotate', '~> 2.4.0' # print out the table structure for models at the top
  gem 'heroku', '~> 1.14.9'
  gem "mongrel", '~> 1.2.0.pre2' # use mongrel instead of webrick for development
end

group :test do
  gem 'pickle', '~> 0.4.4'
  gem 'capybara', '~> 0.4.0'
  gem 'launchy', '~> 0.3.7' # So you can do Then show me the page
  gem 'thin', '~> 1.2.7' # this will speed up your cucumber @javascript tests by a lot
  gem 'factory_girl_rails', :git => 'git://github.com/msgehard/factory_girl_rails.git'
  gem 'database_cleaner', '~> 0.6.0'
  gem 'timecop', '~> 0.3.5'
  #gem 'jasmine'
  gem 'spork', '~> 0.9.0.rc2'
end