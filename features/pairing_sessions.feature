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

  Scenario: Viewing my pairing sessions only shows me the pairing sessions
    in the future
    Given a logged in user exists
    And the time is 11/01/2009 10:00 AM
    And a pairing session exists with owner: the user, description: "Topic for future pairing session", start_at: "11/11/2051 10:00 AM", end_at: "11/11/2051 11:00 AM"
    And a pairing session exists with owner: the user, description: "Topic for past pairing session", start_at: "11/11/2009 10:00 AM", end_at: "11/11/2009 11:00 AM"
    And the time is 11/11/2010 10:00 AM
    When I go to the root page
    And I follow "My Sessions" within the navigation
    Then I should see "Topic for future pairing session" within my pairing sessions
    And I should not see "Topic for past pairing session" within my pairing sessions

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
    And I should see "11/11/2010 10:00AM" within my pairing sessions
		And I should see "11/11/2010 01:00PM" within my pairing sessions
    And I should see "Work on RSpec bugs" within my pairing sessions
    And I should not see "Help fix a bug"

  Scenario: Viewing all my pairing sessions shows me all my pairing sessions including those in the past, and they are sorted oldest to newest
	Given a logged in user exists
	And the time is 11/01/2009 10:00 AM
	And a pairing session exists with owner: the user, description: "Topic for future pairing session", start_at: "11/11/2051 10:00 AM", end_at: "11/11/2051 11:00 AM"
    And a pairing session exists with owner: the user, description: "Topic for past pairing session", start_at: "11/11/2009 10:00 AM", end_at: "11/11/2009 11:00 AM"
    And the time is 11/12/2010 10:00 AM
    When I go to the root page
	And I follow "My Sessions" within the navigation
    And I follow "Show all sessions, including past ones"
    Then I should see "Topic for future pairing session" within my pairing sessions
    And I should see "Topic for past pairing session" within my pairing sessions
 
  @javascript
  Scenario: Delete a pairing session
    Given a logged in user exists
    And a pairing session exists with owner: the user, description: "Help fix a bug"
    When I go to the pairing sessions page
    Then I should see "Help fix a bug"

		When I answer Cancel to any js confirmations
    And I follow "Delete" within my pairing sessions
    Then I should not see "Pairing session was successfully deleted."
    And I should see "Help fix a bug"

		When I answer OK to any js confirmations
    And I follow "Delete" within my pairing sessions
    Then I should see "Pairing session was successfully deleted."
    And I should not see "Help fix a bug"
