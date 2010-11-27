Feature: Managing pairing sessions
  In order to connect with other developers to pair on some code
  As a logged in user
  I want to be able to manage my pairing sessions.

  Background:
    Given the time is 2009-11-01 10:00 AM

  Scenario: Viewing my pairing sessions only shows me the pairing sessions that I have created
    Given a user "another user" exists
    And a pairing session exists with owner: user: "another user", description: "Help fix a bug"
    And a logged in user exists
    And a pairing session exists with owner: the user, description: "Patch Active Record"
    When I go to the root page
    And I follow "My Sessions" within the navigation
    Then I should see "Patch Active Record" within my pairing sessions
    And I should not see "Help fix a bug" within my pairing sessions

  Scenario: Viewing my pairing sessions only shows me the pairing sessions in the future
    Given a user "pair" exists with email: "pair@test.com", first_name: "Hello", last_name: "World"
    And a logged in user exists
    And the following pairing sessions exist
      | owner    | description                      | start_at            | end_at             | pair        |
      | the user | Future pairing session with pair | 2010-11-15 10:00 AM | 2010-11-15 11:00AM | user "pair" |
      | the user | Topic for past pairing session   | 2010-11-12 10:00 AM | 2010-11-12 11:00AM |             |
    And the time is "2010-11-13 10:00 AM"
    When I go to the root page
    And I follow "My Sessions" within the navigation
    Then I should see "Future pairing session with pair" within my pairing sessions
    And I should see "Yes" within my pairing sessions
    And I should not see "Topic for past pairing session" within my pairing sessions

  Scenario: Creating a new pairing session adds the new session to my pairing sessions
    Given I am logged in
    And the location of the new pairing session will be geolocated as "Boulder, CO"
    When I follow "New Pairing session"
    And I fill in "Start Date/Time" with "2010-11-12 10:00 AM"
    And I fill in "End Date/Time" with "2010-11-12 1:00 PM"
    And I fill in "Description" with "Work on RSpec bugs"
    And I fill in "Location" with "Boulder, CO"
    And I press "Create Pairing session"
    Then I should see "Pairing session was successfully created."
    And the "#my_pairing_sessions" table should contain:
      | Start time | End time | Description | Location | Pair | Actions |
      | 2010-11-12 10:00AM | 2010-11-12 01:00PM | Work on RSpec bugs | Boulder, CO | No | Show \| Edit \| Delete |

  Scenario: Editing an existing pairing session
    Given I am logged in
    And a pairing session exists with owner: the user
    And the location of the pairing session will be geolocated as "Boulder, CO"
    When I go to the pairing sessions page
    And I follow "Edit"
    And I fill in "Start Date/Time" with "2010-11-13 10:00 AM"
    And I fill in "End Date/Time" with "2010-11-13 1:00 PM"
    And I fill in "Description" with "Work on RSpec bugs"
    And I fill in "Location" with "Boulder, CO"
    And I press "Update Pairing session"
    Then I should see "Pairing session was successfully updated."
    And the "#my_pairing_sessions" table should contain:
      | Start time | End time | Description | Location | Pair | Actions |
      | 2010-11-13 10:00AM | 2010-11-13 01:00PM | Work on RSpec bugs | Boulder, CO | No | Show \| Edit \| Delete |

  Scenario: Viewing all my pairing sessions shows me my pairing sessions including those in the past, and they are sorted oldest to newest
    Given a logged in user exists
    And a pairing session exists with owner: the user, description: "Topic for future pairing session", start_at: "11/11/2051 10:00 AM", end_at: "11/11/2051 11:00 AM"
    And a pairing session exists with owner: the user, description: "Topic for past pairing session", start_at: "11/11/2009 10:00 AM", end_at: "11/11/2009 11:00 AM"
    And the time is "11/12/2010 10:00 AM"
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

  Scenario: Viewing a list of pairing sessions I can pair on should exclude past sessions
    Given a user "session owner" exists
    And a user "pair" exists
    And a logged in user exists
    And a pairing session exists with owner: user "session owner", description: "Open but past session", start_at: "2010-01-02 10:00 AM", end_at: "2010-01-02 11:00 AM"
    And the time is "2010-01-03 00:00:00"
    And a pairing session exists with owner: user "session owner", description: "Open session", start_at: "2010-01-04 10:00 AM", end_at: "2010-01-04 11:00 AM"
    And a pairing session exists with owner: user "session owner", pair: user "pair", description: "This session taken", start_at: "2010-01-05 10:00 AM", end_at: "2010-01-05 11:00 AM"
    And a pairing session exists with owner: the user, description: "This is my session", start_at: "2010-01-06 10:00 AM", end_at: "2010-01-06 11:00 AM"
    When I go to the pairing sessions page
    Then I should see "Open session" within available pairing sessions
    And I should not see "Open but past session" within available pairing sessions
    And I should not see "This session taken" within available pairing sessions
    And I should not see "This is my session" within available pairing sessions

  Scenario: I can sign up to be the pair for a pairing session I am not the owner of
    Given a user "session owner" exists with email: "session_owner@test.com"
    And a pairing session exists with owner: user: "session owner", description: "Open session", start_at: "2010-11-12 10:00 AM", end_at: "2010-11-12 11:00 AM"
    And a logged in user exists
    When I go to the pairing sessions page
    Then I should see "Open session" within available pairing sessions
    And I should not see "Open session" within sessions I am pairing on
    When I press "I'll pair on this!" within available pairing sessions
    Then I should not see "Open session" within available pairing sessions
    And I should see "You are the lucky winner."
    And I should see "Open session" within sessions I am pairing on
    And I should see "session_owner@test.com" within sessions I am pairing on
    And 1 email should be delivered to user "session owner"
    And the email should have subject: "You have someone to pair with on Open session"
    And the email should have from: "info@promiscuouspairprogramming.com"

  Scenario: I can cancel a pairing session I am not the owner of that I signed up for
    Given a user "session owner" exists
    And a logged in user exists
    And a pairing session exists with owner: user: "session owner", pair: the user, description: "Open session", start_at: "2010-11-12 10:00 AM", end_at: "2010-11-12 11:00 AM"
    And I go to the pairing sessions page
    And I press "Sorry, gotta cancel."
    Then I should not see "Open session" within sessions I am pairing on
    And I should see "Sorry to see you go."
    And I should see "Open session" within available pairing sessions
    And 1 email should be delivered to user "session owner"
    And the email should have subject: "Your pair for Open session has canceled"
    And the email should have from: "info@promiscuouspairprogramming.com"