Feature: Logging in and logging out
  In order to access some portions of the site
  As a registered user
  I want to be able to log in and log out of the site

  Scenario: Log in via user name and password
    Given the following users exists
      | first_name | last_name | email        | password | password_confirmation |
      | Bob        | Test      | bob@test.com | password | password              |
    When I go to the root page
    When I follow "Sign in"
    And I fill in "Email" with "bob@test.com"
    And I fill in "Password" with "password"
    And I press "Sign in"
    Then I should see "Hello Bob Test"
    And I should see "Login successful."

  Scenario: Log out
    Given a logged in user exists
    When I follow "Sign out"
    Then I should see "Signed out successfully."

  Scenario: Try to view pairing sessions page when not logged in
    Given I am on the root page
    When I go to the pairing sessions page
    Then I should be on the new user session page

  Scenario: Log in via Twitter if I am new to the site and not logged into Twitter

  Scenario: Log in via Twitter if I am new to the site and I am logged into Twitter

  Scenario: Log in via Twitter if I have an existing account
