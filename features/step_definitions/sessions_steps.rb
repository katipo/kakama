Given /^I am logged in as "([^\"]*)"$/ do |details|
  do_login(details)
end

Given /^I visit the dashboard before session timeout$/ do
  update_last_request_time_by(Setting.session_timeout.minutes - 1.minute)
  visit dashboard_path
end

Given /^I visit the dashboard after session timeout$/ do
  update_last_request_time_by(Setting.session_timeout.minutes + 1.minute)
  visit dashboard_path
end

When /^I login as "([^\"]*)"$/ do |details|
  do_login(details)
end

Then /^I should be able to login as "([^\"]*)"$/ do |details|
  do_login(details)
end

private

def do_login(details)
  visit logout_url # just incase we are already logged in
  username, password = details.split(':')
  visit login_url
  fill_in "Username", :with => username
  fill_in "Password", :with => (password || 'test')
  click_button "Login"
  response.should have_content('Successfully logged in.')
  @current_staff = Staff.find_by_username!(username.downcase)
end

def update_last_request_time_by(new_time)
  @current_staff.update_attribute(:last_request_at, (@current_staff.last_request_at - new_time))
end
