Feature: Registration
  As an unregistered user
  I want to create a user account
  In order to use the actual features of the site

  Background:
    Given my location will be geolocated as "Aspen, CO"

  Scenario: Creating a user account
    When I go to the home page
    And I follow "Create an account" within the account management section
    And I fill in "First name" with "Bob"
    And I fill in "Last name" with "Test"
    And I fill in "Email" with "bob@test.com"
    And I fill in "Password" with "my_password"
    And I fill in "Confirm password" with "my_password"
    And I press "Sign up"
    Then I should see "Hello Bob Test"
    And I should see "New account created."

  Scenario: Editing my account
    Given I am signed in
    When I follow "Edit my account" within the navigation section
    And I fill in "First name" with "New"
    And I fill in "Last name" with "Name"
    And I press "Update"
    And I should see "You updated your account successfully."
    Then I should see "Hello New Name" within the welcome section
    
  Scenario: Changing my password
    Given I am signed in
    When I follow "Edit my account" within the navigation section
    And I fill in "New password" with "secret"
    And I fill in "Confirm new password" with "secret"
    And I press "Update"
    And I should see "You updated your account successfully."