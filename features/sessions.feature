Feature: Sessions
  In order to restrict content
  I want to be able to require all users login before doing anything
  And be able to logout
  And timeout session if they are inactive for more than what is configured

  Background:
    Given a staff member "Jane" exists

  Scenario: Login with correct details
    When I go to login
    And I fill in "Username" with "jane"
    And I fill in "Password" with "test"
    And I press "Login"
    Then I should see "Successfully logged in."

  Scenario: Login without any details
    When I go to login
    And I press "Login"
    Then I should see "You did not provide any details for authentication."

  Scenario: Login with incorrect username
    When I go to login
    And I fill in "Username" with "invalid"
    And I fill in "Password" with "test"
    And I press "Login"
    Then I should see "Username is not valid"

  Scenario: Login with incorrect password
    When I go to login
    And I fill in "Username" with "jane"
    And I fill in "Password" with "invalid"
    And I press "Login"
    Then I should see "Password is not valid"

  Scenario: Session does not time out before configured cutoff
    Given I am logged in as "jane"
    And I visit the dashboard before session timeout
    Then I should see "Welcome Jane"

  Scenario: Session times out after configured cutoff
    Given I am logged in as "jane"
    And I visit the dashboard after session timeout
    Then I should see "The page you requested requires you be logged in."

  Scenario: Session should store last location for after login
    When I go to the staff list
    Then I should see "The page you requested requires you be logged in."
    When I login as "admin"
    Then I should see "Listing staff members"
