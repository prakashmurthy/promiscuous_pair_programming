# Cities around Boulder:
# * 10 miles: Louisville
# * 20 miles: Broomfield
# * 30 miles: Denver
# * 40 miles: Littleton
# * 50 miles: Fort Collins
 
Factory.define :location_boulder, :class => Location do |f|
  f.raw_location "Boulder, CO"
  f.lat 40.005429
  f.lng -105.251126
  f.street_address "3205 Euclid Ave"
  f.city "Boulder"
  f.province "Boulder"
  f.district nil
  f.state "CO"
  f.zip 80303
  f.country "USA"
  f.country_code "US"
  f.accuracy 8
  f.precision "address"
  f.suggested_bounds "40.0022414,-105.2542036,40.0085366,-105.2479084"
  f.provider "google"
end
 
Factory.define :location_louisville, :class => Location do |f|
  f.raw_location "Louisville, CO"
  f.lat 39.979751
  f.lng -105.1371
  f.street_address "451 499 South St"
  f.city "Louisville"
  f.province "Boulder"
  f.district nil
  f.state "CO"
  f.zip 80027
  f.country "USA"
  f.country_code "US"
  f.accuracy 8
  f.precision "address"
  f.suggested_bounds "39.9765245,-105.1403193,39.9828197,-105.1340241"
  f.provider "google"
end
 
Factory.define :location_broomfield, :class => Location do |f|
  f.raw_location "Broomfield, CO"
  f.lat 39.9231
  f.lng -105.087533
  f.street_address "6 Garden Center"
  f.city "Broomfield"
  f.province "Broomfield"
  f.district nil
  f.state "CO"
  f.zip 80020
  f.country "USA"
  f.country_code "US"
  f.accuracy 8
  f.precision "address"
  f.suggested_bounds "39.9202014,-105.0908036,39.9264966,-105.0845084"
  f.provider "google"
end
 
Factory.define :location_denver, :class => Location do |f|
  f.raw_location "Denver, CO"
  f.lat 39.743098
  f.lng -104.964752
  f.street_address "1658 High St"
  f.city "Denver"
  f.province "Denver"
  f.district nil
  f.state "CO"
  f.zip 80206
  f.country "USA"
  f.country_code "US"
  f.accuracy 8
  f.precision "address"
  f.suggested_bounds "39.7396714,-104.9675556,39.7459666,-104.9612604"
  f.provider "google"
end
 
Factory.define :location_littleton, :class => Location do |f|
  f.raw_location "Littleton, CO"
  f.lat 39.6185649
  f.lng -104.997626
  f.street_address "809 W Crestline Pl"
  f.city "Littleton"
  f.province "Arapahoe"
  f.district nil
  f.state "CO"
  f.zip 80120
  f.country "USA"
  f.country_code "US"
  f.accuracy 8
  f.precision "address"
  f.suggested_bounds "39.6154173,-105.0007736,39.6217125,-104.9944784"
  f.provider "google"
end
 
Factory.define :location_fort_collins, :class => Location do |f|
  f.raw_location "Fort Collins, CO"
  f.lat 40.592791
  f.lng -105.0889399
  f.street_address "416 N Grant Ave"
  f.city "Fort Collins"
  f.province "Larimer"
  f.district nil
  f.state "CO"
  f.zip 80521
  f.country "USA"
  f.country_code "US"
  f.accuracy 8
  f.precision "address"
  f.suggested_bounds "40.5896434,-105.0920875,40.5959386,-105.0857923"
  f.provider "google"
end
 
# Set Boulder to the default location for pairing sessions
Factory.define :location, :parent => :location_boulder do |f|
  # ...
end