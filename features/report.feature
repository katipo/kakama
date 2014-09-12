Feature: Reports
  In order to show reports
  As an administrator
  I want to be able to see reports

  Background:
    Given I am logged in as "admin"
    And a staff member "Gerry" has existed since 6 weeks ago
    And a staff member "Robert" exists

  Scenario: View a list of reports
    When I go to the reports list
    Then I should see "Staff List"
    And I should see "Staff Work History"
    And I should see "Events for a Specific Date"

  Scenario: View the staff list
    When I go to the reports list
    And I click "Staff List"
    Then I should see "Full Name"
    And I should see "Email"
    And I should see "Administrator"
    And I should see "Gerry"

  Scenario: View work history
    Given an approved event "Dinner party" exists at "Civic Square"
    And that event starts in 5 days from now
    And "Gerry" has 1 declined rostering for the "Dinner party" 6 weeks from now
    And "Robert" has 1 no show rostering
    When  I go to the reports list
    And I click "Staff Work History"
    Then I should see "Staff type"
    And I should see "Administrator (admin)"
    And I should see "Gerry"

    When I click "Gerry"
    Then I should see "Work history for Gerry"
    And I should see "Weeks Employed: 6"

    When  I go to the reports list
    And I click "Staff Work History"
    And I click "Robert"
    Then I should see "Work history for Robert"
    And I should see "Total No Shows: 1"
