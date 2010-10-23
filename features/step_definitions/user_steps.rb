Given /^a logged in user exists$/ do
  Given('a user exists with email: "bob@test.com", password: "password", password_confirmation: "password"')
  Given('I go to the root page')
  Given('I follow "Sign in"')
  Given('I fill in "Email" with "bob@test.com"')
  Given('I fill in "Password" with "password"')
  Given('I press "Sign in"')
end