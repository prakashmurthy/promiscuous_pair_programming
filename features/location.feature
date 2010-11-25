Feature: Location
  As a user,
  I want to be able to view pairing sessions around my location
  Since that is most relevant to me.
  
  I also want the default pairing sessions view to originate from my location
  So that I don't have to go through the trouble of telling the system myself
  And I can have a more pleasant experience.
  
  Background:
    Given I am logged in
    And a user "some user" exists
    And the following locations exist:
      | location   | raw_location   | lat       | lng         | street_address   | city       | province | district | state | zip   | country | country_code | accuracy | precision | suggested_bounds                                | provider |
      | Boulder    | Boulder, CO    | 40.005429 | -105.251126 | 3205 Euclid Ave  | Boulder    | Boulder  |          | CO    | 80303 | USA     | US           | 8        | address   | 40.0022414,-105.2542036,40.0085366,-105.2479084 | google   |
      | Louisville | Louisville, CO | 39.979751 | -105.1371   | 451 499 South St | Louisville | Boulder  |          | CO    | 80027 | USA     | US           | 8        | address   | 39.9765245,-105.1403193,39.9828197,-105.1340241 | google   |
      | Denver     | Denver, CO     | 39.743098 | -104.964752 | 1658 High St     | Denver     | Denver   |          | CO    | 80206 | USA     | US           | 8        | address   | 39.7396714,-104.9675556,39.7459666,-104.9612604 | google   |
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
    And the "#available_pairing_sessions" table should contain:
      | Start time         | End time           | Description                       | Location       | Actions |
      | 2010-01-01 12:00AM | 2010-01-02 12:00AM | Pairing session in Boulder, CO    | Boulder, CO    |         |
      | 2010-01-03 12:00AM | 2010-01-04 12:00AM | Pairing session in Louisville, CO | Louisville, CO |         |
    
  Scenario: Setting the location changes the origin of the proximity search, and then remembers the setting
    Given I am on the pairing sessions page
    When I fill in "location" with "Denver, CO" within the pairing sessions form
    And I press "Update list"
    #Then I should still be on the pairing sessions page
    And the "#available_pairing_sessions" table should contain:
      | Start time         | End time           | Description                       | Location       | Actions |
      | 2010-01-05 12:00AM | 2010-01-06 12:00AM | Pairing session in Denver, CO     | Denver, CO     |         |
    When I reload the page
    Then the "location" field within the pairing sessions form should contain "Denver, CO"
    
  Scenario: Setting the radius limits pairing sessions to within the specified proximity of the origin, and then remembers the setting
    Given I am on the pairing sessions page
    When I select "30" from "radius" within the pairing sessions form
    And I press "Update list"
    #Then I should still be on the pairing sessions page
    And the "#available_pairing_sessions" table should contain:
      | Start time         | End time           | Description                       | Location       | Actions |
      | 2010-01-01 12:00AM | 2010-01-02 12:00AM | Pairing session in Boulder, CO    | Boulder, CO    |         |
      | 2010-01-03 12:00AM | 2010-01-04 12:00AM | Pairing session in Louisville, CO | Louisville, CO |         |
      | 2010-01-05 12:00AM | 2010-01-06 12:00AM | Pairing session in Denver, CO     | Denver, CO     |         |
    When I reload the page
    Then the "radius" field within the pairing sessions form should contain "30"