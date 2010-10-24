Feature: Navigation
  In order to provide proper navigation hints to users
  As a website
  I would like to only show specific navigation items to different users

  Scenario: An anonymous user should not see the navigation area
    but should be able to create an account or Log in
    When I go to the root page
    Then I should not see the navigation area
    And I should see "Create an account"
    And I should see "Sign in"
