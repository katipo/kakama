Feature: Venues
  In order to setup events there needs to be venues
  When I try to delete one, it should only work if there are no unfinished events at this venue

  Background:
    Given I am logged in as "admin"

  Scenario: Deleting Venues with no events should work
    Given a venue "The Square" exists
    And I go to the venues list
    Then I should see "The Square"
    When I go to delete the venue
    And I press "Delete"
    Then I should see "Deleted The Square"

  Scenario: Deleting Venues with past events should work
    Given a venue "The Square" exists
    And that venue has past events
    And I go to the venues list
    Then I should see "The Square"
    When I go to delete the venue
    And I press "Delete"
    Then I should see "Deleted The Square"

  Scenario: Deleting Venues with future events doesn't work
    Given a venue "The Square" exists
    And that venue has future events
    And I go to the venues list
    Then I should see "The Square"
    When I try to delete the venue
    Then I should see "The Square can't be destroyed"
    When I go to the venues list
    Then I should see "The Square"

  Scenario: Viewing past events at a venue
    Given an event "A Past Event" exists at "Civic Square"
    And that event finished 1 month ago
    And an event "A Current Event" exists at "Civic Square"
    When I go to view the venue
    Then I should see "A Current Event"
    And I should not see "A Past Event"
    When I follow "View Past Events at this Venue"
    Then I should see "A Past Event"
    And I should not see "A Current Event"

  Scenario: Adding a new event to a venue
    Given a venue "The Square" exists
    And I go to view the venue
    And I follow "Add Event"
    Then I should see "New event"
    And the venues select field should be set to "The Square"
