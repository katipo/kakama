Feature: Rosterings
  In order to assign events to users
  As an administrator, I want to be able to handle rosterings
  By searching for staff to add, approving, rejected, derostering, canceling or marking staff as no shows

  In order to interact with the rosterings given to me
  As a staff member, I want to be able to accept or decline rosterings
  By going to the dashboard and viewing information, then choosing Accept or Decline

  Background:
    Given I am logged in as "admin"
    And an event "Big Concert 1" exists at "Big Stadium 1"
    And that event starts in 5 days from now

    And a staff member "James" exists
    And "James" is not rostered to anything

    And a staff member "Robert" exists
    And "Robert" is not rostered to anything
    And "Robert" is available from 20 days ago till 20 days from now
    And "Robert" has the role "Usher"

  Scenario: Updating required role counts on Working Event
    Given no emails have been sent
    When I go to view the event
    And I update roles to require 1 "Usher"
    Then I should see "(1/1)" within ".selected_staff .usher"
    And I should see "Robert" within ".selected_staff .usher"
    And the staff member "Robert" should receive no emails

  Scenario: Updating required role counts on Approved Event
    Given no emails have been sent
    And that events state is approved
    When I go to view the event
    And I update roles to require 1 "Usher"
    Then I should see "(1/1)" within ".selected_staff .usher"
    And I should see "Robert" within ".selected_staff .usher"
    And "Robert" should receive an email containing details about their new rostering

  Scenario: Approving a working events roster after response cutoff doesn't send notifications
    Given no emails have been sent
    And that event starts in 1 day from now
    When I manually add "Robert" as an "Usher" at the event
    And I finalize that events roster
    Then the staff member "Robert" should receive no emails
    And I should see "The event has passed the cut off date"

  Scenario: Approving a working events roster before response cutoff sends notifications
    Given no emails have been sent
    When I manually add "Robert" as an "Usher" at the event
    And I finalize that events roster
    Then "Robert" should receive an email containing details about their new rostering

  Scenario: Updating required role counts and approving the roster on a Conflicting Event
    Given an event "Big Concert 2" exists at "Big Stadium 1"
    And that event starts in 5 days from now

    When I go to view the event
    And I update roles to require 1 "Usher"
    Then I should see "(1/1)" within ".selected_staff .usher"
    And I should see "Robert" within ".selected_staff .usher"
    And I should see "This event has not been finalised"

    When I finalize that events roster
    Then I should see "Event was successfully updated."
    And I should not see "This event has not been finalised"

  Scenario: Search and Add Available User To Working Event
    Given no emails have been sent
    When I manually add "Robert" as an "Usher" at the event
    Then the staff member "Robert" should receive no emails

  Scenario: Search and Add Available User To Approved Event
    Given no emails have been sent
    And that events state is approved
    When I manually add "Robert" as an "Usher" at the event
    Then "Robert" should receive an email containing details about their new rostering

  Scenario: Search and Add Unavailable User
    When I update roles to require 1 "Usher" without auto rostering
    And I go to view the event
    And I follow "add" within ".selected_staff .usher"
    Then I should see "Search for member to roster"
    And I should not see "James"

    When I follow "View all staff members"
    Then I should see "James"
    When I follow "James"
    Then I should see "James could not be rostered as a Usher to this event."
    And I should see "Are you sure you want to roster this user?"
    When I press "Ignore this Staff Members Unavailability"
    Then I should see "James has been added as a Usher to this event."
    And I should see "(1/1)" within ".selected_staff .usher"
    And I should see "James" within ".selected_staff .usher"

  Scenario: Approve Staff Member Rostering
    Given no emails have been sent
    When I approve "Robert" as an "Usher" at the event
    Then the staff member "Robert" should receive an email
    When they open the email
    Then they should see /your new rostering/ in the email subject
    And they should see "Big Concert 1" in the email body
    And they should see "Big Stadium 1" in the email body

  Scenario: Reject Staff Member Rostering
    When I go to view the event
    And I update roles to require 1 "Usher"
    And I follow "reject" within ".selected_staff .usher"
    Then I should see "Robert has been rejected as a Usher at this event."
    And I should see "Robert" within ".rejected_staff .usher"

  Scenario: Deroster Staff Member Rostering
    When I go to view the event
    And I update roles to require 1 "Usher"
    And I follow "reject" within ".selected_staff .usher"
    Then I should see "Robert" within ".rejected_staff .usher"
    When I follow "deroster" within ".rejected_staff .usher"
    Then I should see "Robert was derostered from this event."
    And I should see "Robert" within ".selected_staff .usher"

  Scenario: Cancel Staff Member Rostering
    When I go to view the event
    And I update roles to require 1 "Usher"
    And I follow "approve" within ".selected_staff .usher"
    Then I should see "Robert has been approved as a Usher at this event."

    Given no emails have been sent
    And I follow "cancel" within ".selected_staff .usher"
    And I fill in "cancel_reason_custom" with "No longer needed."
    And I press "Cancel staff members involvement."
    Then I should see "Robert has been cancelled as a Usher at this event."
    And I should see "Robert" within ".cancelled_staff .usher"
    And the staff member "Robert" should receive an email
    When they open the email
    Then they should see /cancelled your involvement/ in the email subject
    And they should see "No longer needed." in the email body

  Scenario: Mark and Undo No Show Staff Member Rostering
    When I go to view the event
    And I update roles to require 1 "Usher"
    And I follow "approve" within ".selected_staff .usher"
    Then I should see "Robert has been approved as a Usher at this event."

    When I finalize that events roster
    Given that event finished 1 day ago
    When I go to view the event
    Then I should see "This event finished 1 day ago."

    When I follow "no show?" within ".selected_staff .usher"
    Then I should see "Robert has been marked as a no show at this event."
    And I should see "no show" within ".selected_staff .usher"

    When I follow "did show up?" within ".selected_staff .usher"
    Then I should see "Robert has been removed from the no show lists for this event."
    And I should see "attended" within ".selected_staff .usher"

  Scenario: Accept an event rostered to me
    When I go to view the event
    And I update roles to require 1 "Usher"
    And I finalize that events roster
    And I login as "Robert"

    Then I should see "Big Concert 1" within "#upcoming_events"

    When I follow "Accept" within "#upcoming_events"
    Then I should see "You have confirmed your role as a Usher at this event."
    And I should see "You will be sent an email soon confirming the details."

    When I go to the dashboard
    Then I should see "Big Concert 1" within "#upcoming_events"
    And I should see "(confirmed)" within "#upcoming_events"

  Scenario: Decline an event rostered to me
    When I go to view the event
    And I update roles to require 1 "Usher"
    And I finalize that events roster
    And I login as "Robert"

    Then I should see "Big Concert 1" within "#upcoming_events"

    When I follow "Decline" within "#upcoming_events"
    Then I should see "You have declined your role as a Usher at this event."

    When I go to the dashboard
    Then I should not see "Big Concert 1"

  Scenario: Rosterings not shown on the dashboard until event roster approved
    When I go to view the event
    And I update roles to require 1 "Usher"
    And I login as "Robert"

   Then I should not see "Big Concert 1"

  Scenario: Editing Event Name before roster is finalized
    When I go to view the event
    And I update roles to require 1 "Usher"

    Given no emails have been sent
    And I go to edit the event
    And I fill in "Name" with "Something else"
    And I press "Save Event"

    Then the staff member "Robert" should receive no emails

  Scenario: Editing Event Name after roster is finalized
    When I go to view the event
    And I update roles to require 1 "Usher"
    And I finalize that events roster

    Given no emails have been sent
    When I go to edit the event
    And I fill in "Name" with "Something else"
    And I press "Save Event"

    Then the staff member "Robert" should receive an email
    When they open the email
    Then they should see "The event named 'Big Concert 1' has been renamed as 'Something else'" in the email body

  @wip
  Scenario: Editing Event Time without conflicts

  @wip
  Scenario: Editing Event Time with conflicts

  Scenario: Rostering should become declined if user does not respond in time
    Given it is currently 3 weeks ago
    And I am logged in as "admin"
    And an event "Event in the past" exists at "Someplace"
    And that event starts in 21 days from now

    When I go to view the event
    And I update roles to require 1 "Usher"
    And I finalize that events roster

    Given we return to the present
    And all delayed jobs have run
    Then the rostering for "Robert" at the event should be "declined" by the system

  Scenario: Mass Approving Events sends grouped emails to rostered staff
    When I go to view the event
    And I update roles to require 1 "Usher"
    And an event "Big Concert 2" exists at "Big Stadium 2"
    And that event starts in 10 days from now
    And I go to view the event
    And I update roles to require 1 "Usher"

    Given no emails have been sent

    When I go to the working events list
    And I check mass confirm box for "Big Concert 1"
    And I check mass confirm box for "Big Concert 2"
    And I press "Mass Approve Event Rosters"

    Then I should see "selected events have now been approved"
    And the staff member "Robert" should receive an email
    When they open the email
    Then they should see /work at multiple new events/ in the email subject
    And they should see "Big Concert 1" in the email body
    And I should see "Big Concert 2" in the email body

  Scenario: Mass Approving Events, where some staff don't have an email, should send pdfs to administrators for those staff members
    Given a staff member "Sally" exists without an email
    And "Sally" is not rostered to anything
    And "Sally" is available from 20 days ago till 20 days from now
    And "Sally" has the role "Usher"

    When I go to view the event
    And I update roles to require 2 "Usher"
    And an event "Big Concert 2" exists at "Big Stadium 2"
    And that event starts in 10 days from now
    And I go to view the event
    And I update roles to require 2 "Usher"

    Given no emails have been sent

    When I go to the working events list
    And I check mass confirm box for "Big Concert 1"
    And I check mass confirm box for "Big Concert 2"
    And I press "Mass Approve Event Rosters"

    Then I should see "selected events have now been approved"
    And all administrators should receive an email
    When they open the email
    Then there should be an attachment named "multiple_rostering_created_notification_for_sally.pdf"

  @wip
  Scenario: Mass Approving various event types doesn't make delayed jobs that run right away causing double rosterings
