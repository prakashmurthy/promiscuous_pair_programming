Feature: Location
  As a user,
  I want to be able to view pairing sessions around my location
  Since that is most relevant to me.
  
  I also want the default pairing sessions view to originate from my location
  So that I don't have to go through the trouble of telling the system myself
  And I can have a more pleasant experience.
  
  Background:
    Given I am signed in
    And a user "some user" exists
    And Boulder exists as a location
    And Louisville exists as a location
    And Denver exists as a location
    And the time is "2010-01-01 12:00AM"
    And the following pairing sessions exist:
      | owner            | description                       | start_at   | end_at     | location              |
      | user "some user" | Pairing session in Boulder, CO    | 2010-01-01 | 2010-01-02 | location "Boulder"    | 
      | user "some user" | Pairing session in Louisville, CO | 2010-01-03 | 2010-01-04 | location "Louisville" |
      | user "some user" | Pairing session in Denver, CO     | 2010-01-05 | 2010-01-06 | location "Denver"     |
    # This should resolve to Boulder, CO
    And my IP address is "161.97.1.1"
  
  Scenario: Location is automatically detected based on IP address
    When I visit the pairing sessions page
    Then the "location" field within the pairing sessions form should contain "Boulder, CO"
    And the table of my available pairing sessions should contain:
      | Start time         | End time           | Description                       | Location       |
      | 2010-01-03 12:00AM | 2010-01-04 12:00AM | Pairing session in Louisville, CO | Louisville, CO |
      | 2010-01-01 12:00AM | 2010-01-02 12:00AM | Pairing session in Boulder, CO    | Boulder, CO    |
    
  Scenario: Setting the location changes the origin of the proximity search, and then remembers the setting
    Given I am on the pairing sessions page
    When I fill in "location" with "Denver, CO" within the pairing sessions form
    And I press "Update list"
    #Then I should still be on the pairing sessions page
    And the table of my available pairing sessions should contain:
      | Start time         | End time           | Description                       | Location       |
      | 2010-01-05 12:00AM | 2010-01-06 12:00AM | Pairing session in Denver, CO     | Denver, CO     |
    When I reload the page
    Then the "location" field within the pairing sessions form should contain "Denver, CO"
    
  Scenario: Setting the radius limits pairing sessions to within the specified proximity of the origin, and then remembers the setting
    Given I am on the pairing sessions page
    When I select "30" from "radius" within the pairing sessions form
    And I press "Update list"
    #Then I should still be on the pairing sessions page
    And the table of my available pairing sessions should contain:
      | Start time         | End time           | Description                       | Location       |
      | 2010-01-05 12:00AM | 2010-01-06 12:00AM | Pairing session in Denver, CO     | Denver, CO     |
      | 2010-01-03 12:00AM | 2010-01-04 12:00AM | Pairing session in Louisville, CO | Louisville, CO |
      | 2010-01-01 12:00AM | 2010-01-02 12:00AM | Pairing session in Boulder, CO    | Boulder, CO    |
    When I reload the page
    Then the "radius" field within the pairing sessions form should contain "30"