require 'factory_girl_rails'

# this will force you to call one of the
# strategy methods instead of defaulting to .create
# this will speed up the test suite.

class Factory
  def self.default_strategy(name, overrides = {})
    raise 'Please choose a strategy by running Factory.strategy'
  end
end

Factory.find_definitions