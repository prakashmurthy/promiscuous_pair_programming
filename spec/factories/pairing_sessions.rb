# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :pairing_session do |f|
  f.association :owner, :factory => :user
  f.association :location
  f.description "Fixing RSpec bugs"
  f.sequence(:start_at) {|n| n.days.from_now }
  f.end_at {|f| f.start_at + 1.hour }
end