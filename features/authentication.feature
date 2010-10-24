Feature: Logging in and logging out
  In order to access some portions of the site
  As a registered user
  I want to be able to log in and log out of the site

  Scenario: Log in via user name and password
    Given a user exists with email: "bob@test.com", password: "password", password_confirmation: "password"
    When I go to the root page
    When I follow "Sign in"
    And I fill in "Email" with "bob@test.com"
    And I fill in "Password" with "password"
    And I press "Sign in"
    Then I should see "Hello bob@test.com"
    And I should see "Login successful."
@now
  Scenario: Log out
    Given a logged in user exists
    When I follow "Sign out"
    Then I should see "Signed out successfully."

  Scenario: Log in via Twitter if I am new to the site and not logged into Twitter

  Scenario: Log in via Twitter if I am new to the site and I am logged into Twitter

  Scenario: Log in via Twitter if I have an existing account