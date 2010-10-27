# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :pairing_session do |f|
  f.description "Fixing RSpec bugs"
  f.start_at 1.day.from_now
  f.end_at 2.day.from_now
  f.association :owner, :factory => :user
end