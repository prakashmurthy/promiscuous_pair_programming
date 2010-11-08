Feature: Display pairing session on the welcome page
  In order to show non logged in users how much fun we are having
  As a non-logged in user
  I want to display pairing sessions to a non-logged in user

  Scenario: Display a list of open pairing sessions
    Given a user "pair" exists
    And a user "session owner" exists with first_name: "Session", last_name: "Owner", email: "test@test.com"
    Given the following pairing sessions exist
      | description      | start_at           | end_at             | pair         | owner                 |
      | RSpec testing    | 2010-11-15 10:00am | 2010-11-15 11:00am | user: "pair" | user: "session owner" |
      | Cucumber testing | 2010-11-15 11:01am | 2010-11-15 12:00pm |              | user: "session owner" |
    When I go to the home page
    Then I should see "Cucumber testing" within the pairing sessions
    And I should see "Session Owner" within the pairing sessions
    And I should see "2010-11-15 11:01AM" within the pairing sessions
    And I should see "2010-11-15 12:00PM" within the pairing sessions
    And I should not see "test@test.com" within the pairing sessions
    And I should not see "RSpec testing" within the pairing sessions

#  TODO - Add this back in once we figure out how to get pickle to save an invalid record
#  Scenario: Display a list of pairing sessions for a user without a first and last name
#    Given a user "pair" exists
#    And a user "session owner" exists with first_name: "Session", last_name: "Owner", email: "test@test.com" without validation
#    Given the following pairing sessions exist
#      | description      | start_at           | end_at             | pair         | owner                 |
#      | RSpec testing    | 2010-11-15 10:00am | 2010-11-15 11:00am | user: "pair" | user: "session owner" |
#      | Cucumber testing | 2010-11-15 11:01am | 2010-11-15 12:00pm |              | user: "session owner" |
#    When I go to the home page
#    Then I should see "Cucumber testing" within the pairing sessions
#    And I should see "Session Owner" within the pairing sessions
#    And I should see "2010-11-15 11:01AM" within the pairing sessions
#    And I should see "2010-11-15 12:00PM" within the pairing sessions
#    And I should not see "test@test.com" within the pairing sessions
#    And I should not see "RSpec testing" within the pairing sessions