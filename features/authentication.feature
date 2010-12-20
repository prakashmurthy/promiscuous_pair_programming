Feature: Authentication
  As a registered user
  I want to be able to sign into the site
  In order to use the actual features of the site

  Scenario: Signing in via user name and password
    Given the following users exist:
      | first_name | last_name | email        | password | password_confirmation |
      | Bob        | Test      | bob@test.com | password | password              |
    When I go to the home page
    When I follow "Sign in"
    And I fill in "Email" with "bob@test.com"
    And I fill in "Password" with "password"
    And I press "Sign in"
    Then I should see "Hello Bob Test"
    And I should see "Signed in successfully."

  Scenario: Signing out
    Given I am signed in
    When I follow "Sign out"
    Then I should see "Signed out successfully."

  Scenario: Trying to view pairing sessions page when not signed in
    Given I am on the home page
    When I go to the pairing sessions page
    Then I should be on the sign-in page
    And I should see "You need to sign in or sign up before continuing."

  Scenario: Sign in via Twitter if I am new to the site and not signed into Twitter

  Scenario: Sign in via Twitter if I am new to the site and I am signed into Twitter

  Scenario: Sign in via Twitter if I have an existing account
