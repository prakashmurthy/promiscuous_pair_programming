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
    and is available to view
    Given a user "another user" exists
    And a pairing session exists with owner: user: "another user", description: "Help fix a bug"
    And a logged in user exists
    When I follow "New Pairing session"
    And I fill in "Start Date/Time" with "2010-11-12 10:00 AM"
	  And I fill in "End Date/Time" with "2010-11-12 1:00 PM"
    And I fill in "Description" with "Work on RSpec bugs"
    And I press "Create Pairing session"
    Then I should see "Pairing session was successfully created."
    And I should see "2010-11-12 10:00AM" within my pairing sessions
		And I should see "2010-11-12 01:00PM" within my pairing sessions
    And I should see "Work on RSpec bugs" within my pairing sessions
    And I should not see "Help fix a bug" within my pairing sessions

  Scenario: Editing an existing pairing session
    Given a logged in user exists
    And a pairing session exists with owner: the user, start_at: "2010-11-12 10:00 AM", end_at: "2010-11-12 11:00 AM", description: "Help fix a bug"
    When I go to the pairing sessions page
    And I follow "Edit"
    And I fill in "Start Date/Time" with "2010-11-13 10:00 AM"
	  And I fill in "End Date/Time" with "2010-11-13 1:00 PM"
    And I press "Update Pairing session"
    Then I should see "Pairing session was successfully updated."
    And I should see "2010-11-13 10:00AM" within my pairing sessions
		And I should see "2010-11-13 01:00PM" within my pairing sessions
    And I should see "Help fix a bug" within my pairing sessions
    And I should not see "2010-11-12 10:00AM" within my pairing sessions
    And I should not see "2010-11-12 1:00PM" within my pairing sessions

  Scenario: Viewing all my pairing sessions shows me my pairing sessions including those
    in the past, and they are sorted oldest to newest
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

  
#  Pending Scenario: I can sign up to be the pair for a pairing session I am not the owner of
#	Given a logged in user exists
#	And a pairing session exists with owner: "another user", start_at: "2015-10-11 10:00 AM", end_at: "2015-10-11 12:00 PM", description: "Help fix a bug way in the future"
#	When I go to the pairing sessions page
	

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

  Scenario: Viewing a list of pairing sessions that I can pair on.
    Given a user "session owner" exists
    And a user "pair" exists
    And a pairing session exists with owner: user: "session owner", description: "Open session", start_at: "2010-11-12 10:00 AM", end_at: "2010-11-12 11:00 AM"
    And a pairing session exists with owner: user: "session owner", pair: user: "pair", description: "This session taken", start_at: "2010-11-13 10:00 AM", end_at: "2010-11-13 11:00 AM"
    And a logged in user exists
    And a pairing session exists with owner: the user, description: "This is my session", start_at: "2010-11-11 10:00 AM", end_at: "2010-11-11 11:00 AM"
    When I go to the pairing sessions page
    Then I should see "Open session" within available pairing sessions
    And I should not see "This session taken" within available pairing sessions
    And I should not see "This is my session" within available pairing sessions