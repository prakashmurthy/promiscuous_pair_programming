# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :user do |f|
  f.sequence(:email) {|n| "person#{n}@example.com" }
  f.password 'password'
  f.password_confirmation 'password'
end