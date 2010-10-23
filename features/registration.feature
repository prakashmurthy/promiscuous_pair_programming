Feature: Registering new user for the site
  In order to be able to access the site
  As an unregistered user
  I want to create a user account

  Scenario: Creating a user account
    When I go to the root page
    And I follow "Create Account" within the account management section
    And I fill in "Email" with "bob@test.com"
    And I fill in "Password" with "my_password"
    And I fill in "Password confirmation" with "my_password"
    And I press "Sign up"
    Then I should see "Hello bob@test.com"
    And I should see "New account created."