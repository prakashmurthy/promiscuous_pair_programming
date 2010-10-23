Feature: Managing pairing sessions
  In order to connect with other developers to pair on some code
  As a logged in user
  I want to be able to manage my pairing sessions.

  Scenario: Create a new pairing session
    Given a logged in user exists
    When I follow "New Pairing session"
    And I fill in "Date" with "11/10/2010"
    And I fill in "Description" with "Work on RSpec bugs"
    And I press "Create Pairing session"
    Then I should see "Pairing session was successfully created."
    And I should see "11/10/2010" within my pairing sessions
    And I should see "Work on RSpec bugs" within my pairing sessions

  Scenario: Delete a pairing session
    Given a pairing session exists
    And a logged in user exists
    And I am on the pairing sessions page
    When I follow "Delete" within my pairing sessions
    Then I should see "Pairing session was successfully deleted."