Then /^I fill in reset token with "([^\"]*)"$/ do |token|
  enter_reset_token(token)
end

Then /^I fill in reset token with token of "([^\"]*)"$/ do |full_name|
  token = Staff.find_by_full_name!(full_name).perishable_token
  enter_reset_token(token)
end

private

def enter_reset_token(token)
  step 'I go to enter my reset token'
  step "I fill in \"Reset token\" with \"#{token}\""
  step 'I press "Enter reset token"'
end
