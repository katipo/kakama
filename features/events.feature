Feature: Events

  Background:
    Given I am logged in as "admin"
    And a staff member "Gerry" exists
    And "Gerry" is not rostered to anything
    And "Gerry" is available from 20 days ago till 20 days from now
    And "Gerry" has the role "Usher"

  Scenario: Add Event
    When I go to add an event
    And I fill in event details for "Special Day" at "Town Square"
    And I press "Create Event"
    Then I should see "Event was successfully created."
    And I should see "Viewing event details for: Special Day"

  Scenario: Add Event that conflicts
    Given an event "Special Day 1" exists at "Civic Square"
    When I go to add an event
    And I fill in event details for "Special Day 2" at "Civic Square"
    And I press "Create Event"
    Then I should see "The event you're adding conflicts with another one"
    And I should see "The following events were found at this venue at the same time."
    And I should see "Special Day 1"
    When I press "Ignore Conflicts and Create Event"
    Then I should see "Event was successfully created."
    And I should see "Viewing event details for: Special Day"
    And I should see "This event conflicts with the following events at this place and time: Special Day 1"

  Scenario: Add Event that conflicts with old or cancelled event
    Given an event "Special Day 1" exists at "Civic Square"
    And that event starts in 5 days from now
    And that events state is cancelled
    And an event "Special Day 2" exists at "Civic Square"
    And that event starts in 5 days from now
    And that event is deleted
    And an event "Special Day 3" exists at "Civic Square"
    And that event starts in 5 days from now

    When I go to view the event
    Then I should see "This event has not been finalised"
    And I should not see "This event conflicts with the following events"

  Scenario: Edit Event
    Given an event "Special Day" exists at "Civic Square"
    When I go to edit the event
    And I fill in "Name" with "Another Day"
    And I press "Save Event"
    Then I should see "Event was successfully updated."
    And I should see "Viewing event details for: Another Day"

  Scenario: Delete Event not started
    Given an approved event "Special Day" exists at "Civic Square"
    And that event has not started
    When I go to delete the event
    And I press "Yes, I'm sure."
    Then I should see "You cannot delete this event because it has not started. Try canceling it instead."
    Then I should see "Special Day"

  Scenario: Delete Event in progress
    Given an approved event "Special Day" exists at "Civic Square"
    And that event is in progress
    When I go to delete the event
    And I press "Yes, I'm sure."
    Then I should see "You cannot delete this event because it is in progress. Please wait until after."
    Then I should see "Special Day"

  Scenario: Delete Event a week after finished
    Given an approved event "Special Day" exists at "Civic Square"
    And that event finished 1 week ago
    When I go to delete the event
    And I press "Yes, I'm sure."
    Then I should see "You cannot delete this event because one month has not passed. Try again later."
    When I go to the past events list
    Then I should see "Special Day"

  Scenario: Delete Event a month after finished
    Given an event "Special Day" exists at "Civic Square"
    And that event finished 1 month ago
    When I go to delete the event
    And I press "Yes, I'm sure."
    Then I should see "Event was successfully destroyed."
    Then I should not see "Special Day"

  Scenario: Cancel an event not yet started
    Given an event "Special Day" exists at "Civic Square"
    And that event has not started
    When I go to cancel the event
    And I press "Yes, I'm sure."
    Then I should see "Event was successfully cancelled. All involved will be notified."
    Then I should not see "Special Day"

    When I go to the cancelled events list
    And I follow "Special Day"
    Then I should see "Viewing event details for: Special Day"
    And I should see "This event has been cancelled."

  Scenario: Cancel an event in progress
    Given an approved event "Special Day" exists at "Civic Square"
    And that event is in progress
    When I go to cancel the event
    And I press "Yes, I'm sure."
    Then I should see "Event cannot be cancelled because it is in progress."
    Then I should see "Special Day"

  Scenario: Cancel an event after finished
    Given an event "Special Day" exists at "Civic Square"
    And that event finished 1 month ago
    When I go to cancel the event
    And I press "Yes, I'm sure."
    Then I should see "Event cannot be cancelled because it has already happened."

  Scenario: Cancel an event with active rosterings
    Given an event "Special Day" exists at "Civic Square"
    And that event starts in 5 days from now
    When I approve "Gerry" as an "Usher" at the event
    And I go to cancel the event
    And I press "Yes, I'm sure."
    Then I should see "Event was successfully cancelled. All involved will be notified."

  Scenario: Cancelling a working event only sends cancellation emails to confirmed staff
    Given "Gerry" is not rostered to anything
    And a working event "Special Day 1" exists at "Civic Square"
    And that event starts in 5 days from now
    When I go to view the event
    And I update roles to require 1 "Usher"

      Given no emails have been sent
      When I cancel the event
      Then the staff member "Gerry" should receive no emails

    Given "Gerry" is not rostered to anything
    And a working event "Special Day 2" exists at "Civic Square"
    And that event starts in 5 days from now
    When I go to view the event
    And I approve "Gerry" as an "Usher" at the event

      Given no emails have been sent
      When I cancel the event
      Then the staff member "Gerry" should receive an email

  Scenario: Cancelling an approved event sends cancellation emails to all involved staff
    Given "Gerry" is not rostered to anything
    And an approved event "Special Day 1" exists at "Civic Square"
    And that event starts in 5 days from now
    When I go to view the event
    And I update roles to require 1 "Usher"

      Given no emails have been sent
      When I cancel the event
      Then the staff member "Gerry" should receive an email

    Given "Gerry" is not rostered to anything
    And an approved event "Special Day 2" exists at "Civic Square"
    And that event starts in 5 days from now
    When I go to view the event
    And I approve "Gerry" as an "Usher" at the event

      Given no emails have been sent
      When I cancel the event
      Then the staff member "Gerry" should receive an email

  Scenario: Cannot cancel an event twice
    Given an event "Special Day" exists at "Civic Square"
    When I go to cancel the event
    And I press "Yes, I'm sure."
    Then I should see "Event was successfully cancelled. All involved will be notified."
    When I cancel the event
    Then the event should have the error "Event has already been cancelled. You cannot cancel it twice."

  Scenario: Delete Event after being cancelled
    Given an event "Special Day" exists at "Civic Square"
    And that event has not started
    When I go to cancel the event
    And I press "Yes, I'm sure."
    Then I should see "Event was successfully cancelled."
    When I go to delete the event
    And I press "Yes, I'm sure."
    Then I should see "Event was successfully destroyed."

    When I go to view the event
    Then I should see "This event has been deleted."
    When I go to the working events list
    Then I should not see "Special Day"
    When I go to the cancelled events list
    Then I should not see "Special Day"

  Scenario: Admin can access working events
    Given a working event "Working Event" exists at "Civic Square"
    When I go to view the event
    Then I should see "Working Event"

  Scenario: Admin can access approved events
    Given an approved event "Approved Event" exists at "Civic Square"
    When I go to view the event
    Then I should see "Approved Event"

  Scenario: Admin can access cancelled events
    Given a cancelled event "Cancelled Event" exists at "Civic Square"
    When I go to view the event
    Then I should see "Cancelled Event"

  Scenario: Member cannot access working events
    Given I am logged in as "Gerry"
    And a working event "Working Event" exists at "Civic Square"
    When I go to view the event
    Then I should see "You cannot access the event at this time. Please try again later."

  Scenario: Member can access approved events
    Given I am logged in as "Gerry"
    And an approved event "Approved Event" exists at "Civic Square"
    When I go to view the event
    Then I should see "Approved Event"

  Scenario: Member cannot access cancelled events
    Given I am logged in as "Gerry"
    And a cancelled event "Cancelled Event" exists at "Civic Square"
    When I go to view the event
    Then I should see "You cannot access the event at this time. Please try again later."

  Scenario: Contacting Rostered Staff
    Given a staff member "James" exists
    And "James" is "unconfirmed" at the event "Big Concert" as an "Usher"
    And a staff member "Sally" exists
    And "Sally" is "confirmed" at the event "Big Concert" as an "Usher"
    And a staff member "Sue" exists
    And "Sue" is "declined" at the event "Big Concert" as an "Usher"

      Given no emails have been sent
      When I contact "Unconfirmed Staff" about "This" and "That"
      Then the staff member "James" should receive the email I just sent
      But the staff member "Sally" should receive no emails
      And the staff member "Sue" should receive no emails

      Given no emails have been sent
      When I contact "Confirmed Staff" about "This" and "That"
      Then the staff member "Sally" should receive the email I just sent
      But the staff member "James" should receive no emails
      And the staff member "Sue" should receive no emails

      Given no emails have been sent
      When I contact "Unconfirmed and Confirmed Staff" about "This" and "That"
      Then the staff member "James" should receive the email I just sent
      And the staff member "Sally" should receive the email I just sent
      But the staff member "Sue" should receive no emails

      Given no emails have been sent
      When I contact "All (unconfirmed, confirmed, declined)" about "This" and "That"
      Then the staff member "James" should receive the email I just sent
      And the staff member "Sally" should receive the email I just sent
      And the staff member "Sue" should receive the email I just sent

  Scenario: Mass Approving Events
    Given an event "Big Concert 1" exists at "Big Stadium 1"

    When I go to the working events list
    Then I should see "Big Concert 1"

    When I check mass confirm box for "Big Concert 1"
    When I press "Mass Approve Event Rosters"
    Then I should see "selected events have now been approved"

    When I go to the events list
    Then I should see "Big Concert 1"

    When I go to the working events list
    Then I should not see "Big Concert 1"

  Scenario: Mass Approving Events (with conflicting events)
    Given an event "Big Concert 1" exists at "Big Stadium 1"
    And that event starts in 5 days from now
    And an event "Big Concert 2" exists at "Big Stadium 1"
    And that event starts in 5 days from now

    When I go to the working events list
    Then I should see "Big Concert 1"
    And I should see "Big Concert 2"

    When I check mass confirm box for "Big Concert 1"
    And I check mass confirm box for "Big Concert 2"
    When I press "Mass Approve Event Rosters"
    Then I should see "selected events have now been approved"

    When I go to the events list
    Then I should see "Big Concert 1"
    And I should see "Big Concert 2"

    When I go to the working events list
    Then I should not see "Big Concert 1"
    And I should not see "Big Concert 2"

  Scenario: All event types show up on pages they are supposed to
    Given a working event "Big Concert 1" exists at "Big Stadium 1"

      Given that event has not started
      When I go to the working events list
      Then I should see "Big Concert 1"
      When I go to the events list
      Then I should not see "Big Concert 1"

      Given that event starts in 5 hours from now
      And that event ends in 8 hours from now
      When I go to the working events list
      Then I should see "Big Concert 1"
      When I go to the events list
      Then I should not see "Big Concert 1"

      Given that event is in progress
      When I go to the working events list
      Then I should see "Big Concert 1"
      When I go to the events list
      Then I should not see "Big Concert 1"

      Given that event finished 1 month ago
      When I go to the past events list
      Then I should see "Big Concert 1"
      When I go to the working events list
      Then I should not see "Big Concert 1"

    Given an approved event "Big Concert 2" exists at "Big Stadium 2"

      Given that event has not started
      When I go to the events list
      Then I should see "Big Concert 2"

      Given that event starts in 5 hours from now
      And that event ends in 8 hours from now
      When I go to the events list
      Then I should see "Big Concert 2"

      Given that event is in progress
      When I go to the events list
      Then I should see "Big Concert 2"

      Given that event finished 1 month ago
      When I go to the past events list
      Then I should see "Big Concert 2"
      When I go to the events list
      Then I should not see "Big Concert 2"

    Given a cancelled event "Big Concert 3" exists at "Big Concert 3"

      Given that event has not started
      When I go to the cancelled events list
      Then I should see "Big Concert 3"
      When I go to the events list
      Then I should not see "Big Concert 2"

      Given that event starts in 5 hours from now
      And that event ends in 8 hours from now
      When I go to the cancelled events list
      Then I should see "Big Concert 3"
      When I go to the events list
      Then I should not see "Big Concert 2"

      Given that event is in progress
      When I go to the cancelled events list
      Then I should see "Big Concert 3"
      When I go to the events list
      Then I should not see "Big Concert 2"

      Given that event finished 1 month ago
      When I go to the cancelled events list
      Then I should see "Big Concert 3"
      When I go to the events list
      Then I should not see "Big Concert 2"
