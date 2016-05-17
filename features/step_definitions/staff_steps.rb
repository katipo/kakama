Given /^a site admin "([^\"]*)" exists(\swithout an email)?$/ do |full_name, without_email|
  options = without_email ? { :email => '' } : {}
  find_or_create_staff full_name, options.merge(:staff_type => 'admin')
end

Given /^a staff member "([^\"]*)" (?:exists|has existed)(\swithout an email)?(?:\ssince\s)?(.*)$/ do |full_name, without_email, start_date|
  options = without_email ? { :email => '' } : {}
  options.store :start_date, parse_time(start_date) unless start_date.empty?
  options.store :skip_current_password, true
  find_or_create_staff full_name, options
end

Given /^I fill in details for "([^\"]*)"$/ do |full_name|
  And "I fill in \"Username\" with \"#{full_name.split.first.downcase}\""
  And 'I fill in "Password" with "test"'
  And 'I fill in "Password confirmation" with "test"'
  And "I fill in \"Full name\" with \"#{full_name}\""
  And 'I select "Staff Member" from "Staff type"'
end

When /^I send an email to everyone$/ do
  @email_subject = 'sent all staff members an email'
  @message_subject, @message_body = 'Hello', 'Testing'

  When "I go to send everyone an email"
  And "I fill in \"Subject\" with \"#{@message_subject}\""
  And "I fill in \"Email body\" with \"#{@message_body}\""
  And 'I press "Send Email to all Staff Members"'
end

Then /^the staff member "([^\"]*)" should receive ([^\"]*) emails?$/ do |full_name, amount|
  email = full_name ? Staff.find_by_full_name!(full_name).email : Setting.site_administrator_emails.first
  if email.blank?
    raise "ERROR: #{full_name} cannot receive emails because he/she has no email address." unless amount == 'no'
  else
    # It would be better to use should receive here because it is supposed to
    # check unread emails. However there appears to be a bug in email_spec so
    # 'should have' is a workaround.
    Then "\"#{email}\" should have #{amount} emails"
  end
end

Then /^the staff member "([^\"]*)" should receive the email I just sent$/ do |full_name|
  Then "the staff member \"#{full_name}\" should receive an email"
  When 'they open the email'
  Then "they should see /#{@email_subject}/ in the email subject"
  And "they should see \"#{@message_subject}\" in the email body"
  And "they should see \"#{@message_body}\" in the email body"
end

Then /^there should be an email log for "([^\"]*)" about the email I sent to everyone$/ do |full_name|
  staff = Staff.find_by_full_name!(full_name)
  staffs_email_logs = EmailLog.find_all_by_staff_id(staff.id)
  matching_logs = staffs_email_logs.select do |el|
    el.email_type == 'Site Wide email' &&
      el.subject == 'An administrator has sent all staff members an email'
  end
  matching_logs.size.should == 1
end
