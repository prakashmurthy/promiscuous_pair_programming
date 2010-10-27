Feature: Managing pairing sessions
  In order to connect with other developers to pair on some code
  As a logged in user
  I want to be able to manage my pairing sessions.

  Scenario: Viewing my pairing sessions only shows me the pairing sessions
    that I have created
    Given a user "another user" exists
    And a pairing session exists with owner: user: "another user", description: "Help fix a bug"
    And a logged in user exists
    And a pairing session exists with owner: the user, description: "Patch Active Record"
    When I go to the root page
    And I follow "My Sessions" within the navigation
    Then I should see "Patch Active Record" within my pairing sessions
    And I should not see "Help fix a bug" within my pairing sessions

  Scenario: Creating a new pairing session assigns the logged in user as the creator
    Given a user "another user" exists
    And a pairing session exists with owner: user: "another user", description: "Help fix a bug"
    And a logged in user exists
    When I follow "New Pairing session"
    And I fill in "Start at" with "11/11/2010 10:00 AM"
	And I fill in "End at" with "11/11/2010 1:00 PM"
    And I fill in "Description" with "Work on RSpec bugs"
    And I press "Create Pairing session"
    Then I should see "Pairing session was successfully created."
    And I should see "11/11/2010" within my pairing sessions
    And I should see "Work on RSpec bugs" within my pairing sessions
    And I should not see "Help fix a bug"

  Scenario: Delete a pairing session
    Given a logged in user exists
    And a pairing session exists with owner: the user, description: "Help fix a bug"
    When I go to the pairing sessions page
    Then I should see "Help fix a bug"

    When I follow "Delete" within my pairing sessions
    Then I should see "Pairing session was successfully deleted."
    And I should not see "Help fix a bug"
    
  @javascript @wip
  Scenario: Delete a pairing session (Javascript)
    Given a logged in user exists
    And a pairing session exists with owner: the user, description: "Help fix a bug"
    When I go to the pairing sessions page
    Then I should see "Help fix a bug"

    When I follow "Delete" within my pairing sessions
    Then I should see "Pairing session was successfully deleted."
    And I should not see "Help fix a bug"