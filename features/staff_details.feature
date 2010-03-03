Feature: Staff Details
  In order to get in contact with a staff member
  I want each staff member to have multiple points of contact
  And I dont want blank values to be displayed when they are deleted

  Background:
    Given a staff member "Harry" exists
    And I am logged in as "harry"
    And my contact details are set

  Scenario: Add Contact Details
    When I go to my profile
    Then I should see "Viewing profile of Harry"
    And I should see "01 234 5678"

  Scenario: Editing Contact Details
    When I go to edit my details
    And I fill in "Home Phone" with "98 765 4321"
    And I press "Save"
    Then I should see "Viewing profile of Harry"
    And I should see "98 765 4321"

  Scenario: Deleting Contact Details
    When I go to edit my details
    And I fill in "Home Phone" with ""
    And I press "Save"
    Then I should see "Viewing profile of Harry"
    And I should not see "Home Phone"
