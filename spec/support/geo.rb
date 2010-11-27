RSpec.configuration.before(:suite) do
  # Prevent no more calls to the Google Maps API than are necessary
  Location.geocoding_disabled = true
end