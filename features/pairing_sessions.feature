Feature: Managing pairing sessions
  As a signed-in user
  I want to be able to manage my pairing sessions
  In order to connect with other developers to pair on some code.

  Background:
    Given I am signed in

  Scenario: Creating a new pairing session adds the new session to my open pairing sessions
    Given the location of the new pairing session will be geolocated as "Aspen, CO"
    When I follow "New Pairing session"
    And I fill in "Start Date/Time" with "2010-11-12 10:00 AM"
    And I fill in "End Date/Time" with "2010-11-12 1:00 PM"
    And I fill in "Description" with "Work on RSpec bugs"
    And I fill in "Location" with "Aspen, CO"
    And I press "Create Pairing session"
    Then I should see "Pairing session was successfully created."
    And the table of my open pairing sessions should contain:
      | Start time         | End time           | Description        |
      | 2010-11-12 10:00AM | 2010-11-12 01:00PM | Work on RSpec bugs |

  Scenario: Editing an existing pairing session
    And a pairing session exists with owner: user "me"
    And the location of the pairing session will be geolocated as "Aspen, CO"
    When I go to the pairing sessions page
    And I follow "Edit"
    And I fill in "Start Date/Time" with "2010-11-12 10:00 AM"
    And I fill in "End Date/Time" with "2010-11-12 1:00 PM"
    And I fill in "Description" with "Work on RSpec bugs"
    And I fill in "Location" with "Aspen, CO"
    And I press "Update Pairing session"
    Then I should see "Pairing session was successfully updated."
    And the table of my open pairing sessions should contain:
      | Start time         | End time           | Description        |
      | 2010-11-12 10:00AM | 2010-11-12 01:00PM | Work on RSpec bugs |

  @javascript
  Scenario: Deleting a pairing session asks you to confirm the deletion
    And a pairing session exists with owner: user "me", description: "Help fix a bug"
    When I go to the pairing sessions page
    Then I should see "Help fix a bug" within my open pairing sessions

    Given I will reject any Javascript confirmation
    When I follow "Delete" within my open pairing sessions
    Then I should not see "Pairing session was successfully deleted."
    When I reload the page
    Then I should still see "Help fix a bug" within my open pairing sessions

    Given I will accept any Javascript confirmation
    When I follow "Delete" within my open pairing sessions
    Then I should see "Pairing session was successfully deleted."
    And I should no longer see "Help fix a bug" within my open pairing sessions
    
  Scenario: When I delete a pairing session that I own, without a pair, the session is removed from the system and no email is sent out
    And a pairing session exists with owner: user "me", description: "Help fix a bug"
    When I go to the pairing sessions page
    Then I should see "Help fix a bug" within my open pairing sessions

    When I follow "Delete" within my open pairing sessions
    Then I should not see "Help fix a bug" within my open pairing sessions
    And a pairing session should not exist with description: "Help fix a bug"
    And 0 emails should be delivered

  Scenario: When I delete a pairing session that I own, with a pair, the session is removed from the system and the pair is alerted via email
    Given a user "pair" exists
    And the following pairing sessions exist
      | owner     | pair        | description                 | start_at            | end_at             |
      | user "me" | user "pair" | Pairing session with a pair | 2010-11-15 10:00 AM | 2010-11-15 11:00AM |
      
    When I go to the pairing sessions page
    Then I should see "Pairing session with a pair" within my involved pairing sessions
    
    When I follow "Delete" within my involved pairing sessions
    Then I should not see "Pairing session with a pair" within my involved pairing sessions
    And a pairing session should not exist with description: "Pairing session with a pair"
    And 1 email should be delivered to user "pair"
    And the email should have subject: "The pairing session Pairing session with a pair has been canceled"
    And the email should have from: "info@promiscuouspairprogramming.com"

  Scenario: Joining a pairing session
    Given a user "session owner" exists with email: "session_owner@test.com"
    And a pairing session exists with owner: user "session owner", description: "Open session"
    
    When I go to the pairing sessions page
    Then I should see "Open session" within available pairing sessions
    And I should not see "Open session" within my involved pairing sessions
    
    When I press "I'll pair on this!" within available pairing sessions
    Then I should see "You are the lucky winner."
    And I should not see "Open session" within available pairing sessions
    And I should see "Open session" within my involved pairing sessions
    And 1 email should be delivered to user "session owner"
    And the email should be from: "info@promiscuouspairprogramming.com", subject: "You have someone to pair with on Open session"

  Scenario: Backing out of a pairing session
    Given a user "session owner" exists
    And a pairing session exists with owner: user: "session owner", pair: user "me", description: "Open session"
    
    When I go to the pairing sessions page
    Then I should see "Open session" within my involved pairing sessions
    And I should not see "Open session" within available pairing sessions 
    
    When I press "Sorry, gotta cancel."
    Then I should see "Sorry to see you go."
    And I should not see "Open session" within my involved pairing sessions
    And I should see "Open session" within available pairing sessions
    And 1 email should be delivered to user "session owner"
    And the email should be from: "info@promiscuouspairprogramming.com", subject: "Your pair for Open session has canceled"