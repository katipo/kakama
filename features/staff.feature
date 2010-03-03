Feature: Staff
  In order to keep staff information up to date
  As a site administrator
  I want to create, update, and delete staff
  And as a staff member
  I want to be able to update my own information

  Background:
    Given a staff member "Joe" exists

  Scenario: Add Staff as Administrator without email
    Given I am logged in as "admin"
    When I go to add a new staff member
    And I fill in details for "Jack"
    And I press "Create Staff"
    Then I should see "Staff was successfully created. This user must be notified manually that their account has been created."
    And I should see "Viewing profile of Jack"

  Scenario: Add Staff as Administrator with email
    Given I am logged in as "admin"
    And no emails have been sent
    When I go to add a new staff member
    And I fill in details for "Jack"
    And I fill in "Email" with "jack@example.com"
    And I press "Create Staff"
    Then I should see "Staff was successfully created. The user has been emailed notifying them of their account has been created."
    And I should see "Viewing profile of Jack"
    Then "jack@example.com" should receive an email
    When they open the email
    Then they should see /An account has been created for you/ in the email subject

  Scenario: Edit Staff as Administrator
    Given I am logged in as "admin"
    When I go to edit the staff member "Joe"
    And I fill in "Full name" with "Jim"
    And I press "Save"
    Then I should see "Staff was successfully updated."
    And I should see "Viewing profile of Jim"

  Scenario: Delete Staff without rosterings as Administrator works
    Given I am logged in as "admin"
    When I go to delete the staff member "Joe"
    And I press "Yes, I'm sure."
    Then I should see "Staff was successfully destroyed."

  Scenario: Delete Staff with active rosterings as Administrator rejected
    Given I am logged in as "admin"
    And "Joe" is "confirmed" for the event "Big Concert" as an "Usher"
    When I go to delete the staff member "Joe"
    And I press "Yes, I'm sure."
    Then I should see "Unable to delete the staff member Joe."
    And I should see "They are currently unconfirmed or confirmed at one or more events."
    And I should see "They need to be removed from these events before they can be deleted."

  Scenario: Delete Staff with inactive rosterings as Administrator works
    Given I am logged in as "admin"
    And "Joe" was "declined" for the event "Big Concert" as an "Usher"
    When I go to delete the staff member "Joe"
    And I press "Yes, I'm sure."
    Then I should see "Staff was successfully destroyed."

  Scenario: Change Password as Administrator
    Given I am logged in as "admin"
    When I go to edit the staff member "Joe"
    And I fill in "Password" with "newpass"
    And I fill in "Password Confirmation" with "newpass"
    And I press "Save"
    Then I should see "Staff was successfully updated."
    When I go to logout
    Then I should be able to login as "joe:newpass"

  Scenario: Edit Details as Staff Member
    Given I am logged in as "joe"
    When I go to edit my details
    And I fill in "Full name" with "Jim"
    And I press "Save"
    Then I should see "Staff was successfully updated."
    And I should see "Viewing profile of Jim"

  Scenario: Change Password as Staff Member without current password set
    Given I am logged in as "joe"
    When I go to edit my details
    And I fill in "Password" with "newpass"
    And I fill in "Password Confirmation" with "newpass"
    And I press "Save"
    Then I should see "Current password must be set when changing the password."

  Scenario: Change Password as Staff Member with current password set
    Given I am logged in as "joe"
    When I go to edit my details
    And I fill in "Current password" with "test"
    And I fill in "Password" with "newpass"
    And I fill in "Password Confirmation" with "newpass"
    And I press "Save"
    Then I should see "Staff was successfully updated."
    When I go to logout
    Then I should be able to login as "joe:newpass"

  Scenario: Search for Staff Members
    Given I am logged in as "admin"
    And a staff member "Busy Bee" exists
    And a staff member "Flat Tack" exists
    When I go to the staff list
    Then I should see "Busy Bee"
    And I should see "Flat Tack"
    When I fill in "search_text" with "Flat"
    And I press "Search Members"
    Then I should see "Flat Tack"
    And I should not see "Busy Bee"

  Scenario: Staff should have correct information on the Dashboard
    Given an approved event "Big Concert 1" exists at "Small Civic Square"
    And that event finished 1 month ago
    And "Joe" was "confirmed" at that event as an "Usher"

    And an approved event "Big Concert 2" exists at "Medium Civic Square"
    And that event is in progress
    And "Joe" was "confirmed" at that event as an "Usher"

    And an approved event "Big Concert 3" exists at "Large Civic Square"
    And that event has not started
    And "Joe" is "confirmed" at that event as an "Usher"

    And a working event "Big Concert 4" exists at "Mega Civic Square"
    And that event starts in 2 weeks from now
    And "Joe" is "confirmed" at that event as an "Usher"

    And I am logged in as "Joe"
    When I go to the dashboard

    Then I should see "Big Concert 1" within "#past_events"
    And I should not see "Big Concert 2" within "#past_events"
    And I should not see "Big Concert 3" within "#past_events"

    And I should see "Big Concert 2" within "#current_events"
    And I should not see "Big Concert 1" within "#current_events"
    And I should not see "Big Concert 3" within "#current_events"

    And I should see "Big Concert 3" within "#upcoming_events"
    And I should not see "Big Concert 1" within "#upcoming_events"
    And I should not see "Big Concert 2" within "#upcoming_events"

    And I should not see "Big Concert 4" within "#upcoming_events"

  Scenario: Send a personal email to a user with an email
    Given I am logged in as "admin"
    And no emails have been sent

    When I go to send "Joe" an email
    And I fill in "Subject" with "Hello"
    And I fill in "Email body" with "Testing"
    And I press "Send Email to Joe"

    Then I should see "Joe was sent the email you submitted."
    And the staff member "Joe" should receive an email
    When they open the email
    Then they should see /personalized email/ in the email subject
    And they should see "Hello" in the email body
    And they should see "Testing" in the email body

  Scenario: Send a personal email to a user without an email
    Given a staff member "Jill" exists without an email
    And I am logged in as "admin"

    When I go to send "Jill" an email
    Then I should see "You cannot send Jill an email because they have no email set."

  Scenario: Sending out email to all staff members
    Given I am logged in as "admin"
    And a staff member "Jill" exists
    And no emails have been sent

    When I send an email to everyone
    Then I should see "Email was sent to all staff members."
    And the staff member "Joe" should receive the email I just sent
    And the staff member "Jill" should receive the email I just sent

  Scenario: Sending out email to all staff members CCs admins
    Given I am logged in as "admin"
    And a staff member "Jill" exists
    And no emails have been sent
    And administrators get all emails

    When I send an email to everyone
    Then all administrators should receive an email

  Scenario: Sending out email to all staff members keeps an email log
    Given I am logged in as "admin"
    And a staff member "Jill" exists
    And no emails have been sent

    When I send an email to everyone
    Then I should see "Email was sent to all staff members."
    And there should be an email log for "Jill" about the email I sent to everyone

  Scenario: Sending out email to all staff members, where staff haven't got an email, sends pdfs to admins
    Given I am logged in as "admin"
    And a staff member "Sally" exists without an email
    And a staff member "Jim" exists without an email
    And no emails have been sent
    And administrators dont get all emails

    When I send an email to everyone
    Then all administrators should receive an email
