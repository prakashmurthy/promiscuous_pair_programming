Feature: Listing pairing sessions
  As a registered user
  I want to be able to see a list of all the pairing sessions I've created but have yet to be paired on
  So that I can check back later and quickly see if the situation has changed
   
  Background:
    Given I am signed in
    Given a user "Joe" exists with first_name: "Joe", last_name: "Bloe"
    And the following locations exist:
      | location   | raw_location   | lat       | lng         | street_address   | city       | province | district | state | zip   | country | country_code | accuracy | precision | suggested_bounds                                | provider |
      | Boulder    | Boulder, CO    | 40.005429 | -105.251126 | 3205 Euclid Ave  | Boulder    | Boulder  |          | CO    | 80303 | USA     | US           | 8        | address   | 40.0022414,-105.2542036,40.0085366,-105.2479084 | google   |
    And the time is "2009-12-26 00:00:00"
    And the following pairing sessions exist:
      | owner      | pair      | description                                   | start_at           | end_at             | location           |
      | user "me"  |           | My old pairing session request, no takers     | 2009-12-30 12:00AM | 2009-12-30 01:00AM |                    |
      | user "Joe" | user "me" | My old session with Joe                       | 2009-12-29 12:00AM | 2009-12-29 01:00AM |                    |
      | user "Joe" |           | Joe's old pairing session request, no takers  | 2009-12-28 12:00AM | 2009-12-28 01:00AM |                    |
      | user "Joe" | user "me" | Joe's old session with me                     | 2009-12-27 12:00AM | 2009-12-27 01:00AM |                    |
    And the time is "2010-01-01 00:00:00"
    And the following pairing sessions exist:
      | owner      | pair      | description                                   | start_at           | end_at             | location           |
      | user "me"  |           | My pairing session request, takers pending    | 2010-01-02 12:00AM | 2010-01-02 01:00AM |                    |
      | user "Joe" | user "me" | My upcoming session with Joe                  | 2010-01-03 12:00AM | 2010-01-03 01:00AM |                    |
      | user "Joe" |           | Joe's pairing session request, takers pending | 2010-01-04 12:00AM | 2010-01-04 01:00AM | location "Boulder" |
      | user "Joe" | user "me" | Joe's upcoming session with me                | 2010-01-05 12:00AM | 2010-01-05 01:00AM |                    |
   
  Scenario: The "my commitments" list shows only sessions where I'm either owner or pair, sorted newest to oldest
    When I go to the pairing sessions page
    Then the table of my involved pairing sessions should contain:
      | Start time         | End time           | Description                    | Partner  |
      | 2010-01-05 12:00AM | 2010-01-05 01:00AM | Joe's upcoming session with me | Joe Bloe |
      | 2010-01-03 12:00AM | 2010-01-03 01:00AM | My upcoming session with Joe   | Joe Bloe |
       
  Scenario: Showing old pairing sessions expands the "my commitments" list to show sessions in the past
    When I go to the pairing sessions page
    And I follow "Show old pairing sessions"
    Then the table of my involved pairing sessions should contain:
      | Start time         | End time           | Description                    | Partner  |
      | 2010-01-05 12:00AM | 2010-01-05 01:00AM | Joe's upcoming session with me | Joe Bloe |
      | 2010-01-03 12:00AM | 2010-01-03 01:00AM | My upcoming session with Joe   | Joe Bloe |
      | 2009-12-29 12:00AM | 2009-12-29 01:00AM | My old session with Joe        | Joe Bloe |
      | 2009-12-27 12:00AM | 2009-12-27 01:00AM | Joe's old session with me      | Joe Bloe |
   
  Scenario: The "my open sessions" list shows only sessions I own but don't have a pair, sorted newest to oldest
    When I go to the pairing sessions page
    Then the table of my open pairing sessions should contain:
      | Start time         | End time           | Description                                |
      | 2010-01-02 12:00AM | 2010-01-02 01:00AM | My pairing session request, takers pending |
      | 2009-12-30 12:00AM | 2009-12-30 01:00AM | My old pairing session request, no takers  |
   
  Scenario: The "available pairing sessions" list shows only unpaired, current sessions created by other people, sorted newest to oldest
    Given a user "Steve" exists with first_name: "Steve", last_name: "Schmoe"
    Given the following pairing sessions exist:
      | owner        | pair | description                                     | start_at           | end_at             | location           |
      | user "Steve" |      | Steve's pairing session request, takers pending | 2010-01-04 06:00AM | 2010-01-04 07:00AM | location "Boulder" |
    When I go to the pairing sessions page
    Then the table of available pairing sessions should contain:
      | Start time         | End time           | Description                                     | Location    |
      | 2010-01-04 06:00AM | 2010-01-04 07:00AM | Steve's pairing session request, takers pending | Boulder, CO |
      | 2010-01-04 12:00AM | 2010-01-04 01:00AM | Joe's pairing session request, takers pending   | Boulder, CO |