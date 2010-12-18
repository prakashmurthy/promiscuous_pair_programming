Feature: Navigation
  As the developers
  I want to show specific navigation items to users depending on whether they're signed in
  So that users know what to do

  Scenario: Viewing the home page as an anonymous user
    When I go to the home page
    Then I should not see the navigation area
    And I should see "Create an account"
    And I should see "Sign in"

  Scenario: Viewing the home page as a signed-in user
    Given I am signed in
    When I go to the home page
    Then I should see the navigation area
    And I should not see "Create an account"
    And I should not see "Sign in"
    And I should see "Sign out"
