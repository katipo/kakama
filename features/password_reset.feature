Feature: Password Reset
  In order to reset my password incase I forget it
  I want to be able to request a reset
  And receive an email with reset instructions
  Which when followed, work as expected.

  Background:
    Given a staff member "Hommer" exists
    And no emails have been sent

  Scenario: Request Reset with incorrect email
    When I go to reset my password
    And I fill in "Email" with "no-valid@example.com"
    And I press "Reset my password"
    Then I should see "No user was found with that email address."

  Scenario: Request Reset with correct email
    When I go to reset my password
    And I fill in "Email" with "hommer@example.com"
    And I press "Reset my password"
    Then I should see "Instructions to reset your password have been emailed to you."
    And the staff member "Hommer" should receive an email
    When I open the email
    Then I should see "A request to reset your password has been made" in the email body
    And I should see "Continue to reset your password" in the email body
    When I follow "Continue to reset your password" in the email
    Then I should see "Change My Password"
    When I fill in "Password" with "newpass"
    And I fill in "Password confirmation" with "newpass"
    And I press "Update my password"
    Then I should see "Password successfully updated. You have now been logged in."
    And I should see "Welcome Hommer"
    When I go to logout
    Then I should be able to login as "hommer:newpass"

  Scenario: Enter invalid reset token
    When I fill in reset token with "invalid"
    Then I should see "Invalid password reset request."

  Scenario: Enter valid reset token
    When I fill in reset token with token of "Hommer"
    Then I should see "Change My Password"
