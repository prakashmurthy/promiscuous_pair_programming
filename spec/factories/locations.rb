Factory.define :location do |f|
  f.raw_location "1521 Pearl St, Boulder, CO, 80302"
  f.lat 40.0189782
  f.lng -105.2753118
  f.street_address "1521 Pearl St"
  f.city "Boulder"
  f.province "Boulder"
  f.district nil
  f.state "CO"
  f.zip "80302"
  f.country "USA"
  f.country_code "US"
  f.accuracy 8
  f.precision "address"
  f.suggested_bounds "40.0158306,-105.2784594,40.0221258,-105.2721642"
  f.provider "google"
end