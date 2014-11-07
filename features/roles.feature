Feature: Roles
  In order to assign staff different roles
  As an administrator
  I want to be able to assign then on staff creation or edit

  Background:
    Given I am logged in as "admin"

  Scenario: Add staff with roles
    When I go to add a new staff member
    And I fill in details for "Bill"
    And I select "Coat Check" from "Roles"
    And I press "Create Staff"
    Then I should see "Staff was successfully created."
    And I should see "Coat Check"

  # TODO: Come back to this when webrat supports it
  # Webrat doesn't support multiples values past the first one (patch has been submitted)
  #
  # Scenario: Edit staff with roles
  #   When I go to edit my details
  #   And I select "Coat Check" from "Roles"
  #   And I press "Save"
  #   Then I should see "Staff was successfully updated."
  #   And I should see "Coat Check"
  #   When I go to edit my details
  #   And I select "Receptionist" from "Roles"
  #   And I select "Supervisor" from "Roles"
  #   And I press "Save"
  #   Then I should see "Staff was successfully updated."
  #   And I should not see "Coat Check"
  #   And I should see "Receptionist"
  #   And I should see "Supervisor"

  Scenario: Cannot Delete a role with staff assigned
    Given a staff member "Joe" exists
    And they have the role "Usher"
    When I try to delete the role "Usher"
    Then I should see "Usher can't be destroyed"
    When I go to the roles list
    Then I should see "Usher"
