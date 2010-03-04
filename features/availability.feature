Feature: Availability
  In order to mark when a staff member is available
  Staff can set which time period they are available
  And which hours in that period
  In order to prevent staff from changing admin set values
  Staff cannot cannot change availabilities that have been locked by an admin

  Background:
    Given a staff member "Gerry" exists
    And I am logged in as "gerry"

  Scenario: Adding Availability
    When I go to add an availability
    And I mark now till 5 days from now as available
    And I press "Create Availability"
    Then I should see "Availability was successfully created."

  Scenario: Adding Availability that conflicts
    Given I am available from now till 2 days from now
    And I go to add an availability
    And I mark now till 2 days from now as available
    And I press "Create Availability"
    Then I should see "The following conflicting availability was found."
    And I should not see "Ignore Conflicts and Create Availability"
    When I click on one of the conflicting availabilities
    Then I should see "Edit Availability"

  Scenario: Adding Availability that conflicts as admin
    Given I am logged in as "admin"
    And I am available from now till 2 days from now
    And I go to add an availability
    And I mark now till 2 days from now as available
    And I press "Create Availability"
    Then I should see "The following conflicting availability was found."
    When I press "Ignore Conflicts and Create Availability"
    Then I should see "Availability was successfully created."

  Scenario: Editing Availability
    Given I am available from now till 2 days from now
    When I go to edit my current availability
    Then I should see "Edit Availability"
    When I mark 1 day from now till 3 days from now as available
    And I press "Update Availability"
    Then I should see "Availability was successfully updated."

  Scenario: Editing Availability that conflicts
    Given I am available from now till 2 days from now
    And I am available from 3 days from now till 4 days from now
    When I go to edit my current availability
    Then I should see "Edit Availability"
    When I mark 3 days from now till 4 days from now as available
    And I press "Update Availability"
    Then I should see "The following conflicting availability was found."
    And I should not see "Ignore Conflicts and Save Availability"
    When I click on one of the conflicting availabilities
    Then I should see "Edit Availability"

  Scenario: Editing Availability that conflicts as admin
    Given I am logged in as "admin"
    And I am available from now till 2 days from now
    And I am available from 3 days from now till 4 days from now
    When I go to edit my current availability
    Then I should see "Edit Availability"
    When I mark 3 days from now till 4 days from now as available
    And I press "Update Availability"
    Then I should see "The following conflicting availability was found."
    When I press "Ignore Conflicts and Save Availability"
    Then I should see "Availability was successfully updated."

  Scenario: Editing Availability locked by an admin, then unlocked
    Given I am logged in as "admin"
    And "Gerry" is available from 1 day from now till 2 days from now
    When I go to edit the current availability of "Gerry"
    And I mark now till 2 days from now as available
    And I check "Lock this Availability?"
    And I press "Update Availability"
    Then I should see "Availability was successfully updated."

    Given I am logged in as "gerry"
    And I go to edit my current availability
    Then I should see "This Availability has been locked by an administrator. You cannot edit it until they unlock it."

    Given I am logged in as "admin"
    When I go to edit the current availability of "Gerry"
    And I uncheck "Lock this Availability?"
    And I press "Update Availability"
    Then I should see "Availability was successfully updated."

    Given I am logged in as "gerry"
    And I go to edit my current availability
    Then I should see "Edit Availability"

  Scenario: Removing Availability
    Given I am available from now till 2 days from now
    When I go to remove my current availability
    And I press "Yes, I'm sure."
    Then I should see "Availability was successfully removed."
    When I go to edit my current availability
    Then I should see "Add Availability"

  Scenario: Notifying administrators of availability change
    Given no emails have been sent
    When I go to edit my current availability
    And I mark 2009-08-31 till 2009-09-02 as available
    And I fill in "Notification Comment" with "The next few days availability"
    And I press "Create Availability"
    Then all administrators should receive an email
    When they open the email
    Then they should see /Availability of Gerry has been changed/ in the email subject
    When they follow "View the new availability" in the email
    Then I should see "Availability of Gerry for the week of 31-08-2009"

  Scenario: Notifying the staff member of changes to their availability
    Given no emails have been sent
    And I am logged in as "admin"
    When I go to edit the current availability of "Gerry"
    And I mark 2009-08-31 till 2009-09-02 as available
    And I fill in "Notification Comment" with "I've set you to work now"
    And I press "Create Availability"
    Then the staff member "Gerry" should receive an email
    When they open the email
    Then they should see /Your availability has been changed by an administrator/ in the email subject
    When they follow "View the new availability" in the email
    Then I should see "Availability of Gerry for the week of 31-08-2009"

  Scenario: An administrator changing their own availability should send no notifications
    Given no emails have been sent
    And I am logged in as "admin"
    When I go to edit my current availability
    Then I should not see "Additional Information"
    When I mark 2009-08-31 till 2009-09-02 as available
    And I press "Create Availability"
    Then all administrators should receive no emails

  Scenario: When notification comment is empty, no emails should be sent
    Given no emails have been sent
    When I go to edit my current availability
    And I mark 2009-08-31 till 2009-09-02 as available
    And I press "Create Availability"
    Then all administrators should receive no emails

  Scenario: When the staff member is rostered to something, they can't make changes to that availability
    Given I am available from now till 6 days from now
    And I am "confirmed" for the event "Big Concert" as an "Usher"
    When I go to edit my current availability
    Then I should see "You can't edit or delete this availability because you are rostered to an event at this time."

  Scenario: When the staff member is rostered to something, the admin sees a warning about the conflicts
    Given I am available from now till 6 days from now
    And I am "confirmed" for the event "Big Concert" as an "Usher"
    When I login as "admin"
    And I go to edit the current availability of "Gerry"
    Then I should see "Caution: This staff member has events rostered during this availability."
    And I should see "Editing it could conflict with these events."

  Scenario: Splitting an availability that isn't used
    Given I am available from now till 6 days from now

    When I split my current availability at 3 days from now
    Then I should see "Your availability has been split on the date specified."
    And I should have 2 availabilities
    And availability 1 should be from now till 2 days from now
    And availability 2 should be from 3 days from now till 6 days from now

  Scenario: Splitting an availability that has an event occurring at the split time
    Given I am available from now till 6 days from now
    And I am "confirmed" for the event "Big Concert" as an "Usher"

    When I split my current availability at 3 days from now
    Then I should see "You cannot split your availability here because there are events overlapping it."
    And I should have 1 availability

  Scenario: Splitting an availability that has an event occurring in the same time period
    Given I am available from now till 20 days from now
    And I am "confirmed" for the event "Big Concert" as an "Usher"

    When I split my current availability at 15 days from now
    Then I should see "Your availability has been split on the date specified."
    And I should have 2 availabilities
    And availability 1 should be from now till 14 days from now
    And availability 2 should be from 15 days from now till 20 days from now

  Scenario: Splitting an availability without a split date shows error
    Given I am available from now till 6 days from now

    When I go to split my current availability
    And I press "Split Availability"
    Then I should see "You left the split date empty. You must supply one."

  Scenario: Splitting an availability with a date outside it's start and end dates
    Given I am available from now till 6 days from now

    When I split my current availability at 1 day ago
    Then I should see "The split date must be after this availabilities start date."
    And I should have 1 availability

    When I split my current availability at 10 days from now
    Then I should see "The split date must be on or before this availabilities end date."
    And I should have 1 availability

  Scenario: Splitting an availability so I can take a holiday
    Given I am available from now till 30 days from now

    When I split my current availability at 10 days from now
    And I split availability 2 at 20 days from now
    Then I should have 3 availabilities

    When I delete availability 2
    Then I should have 2 availabilities
    And availability 1 should be from now till 9 days from now
    And availability 2 should be from 20 days from now till 30 days from now
