rostering_regex = '^(?:I|"([^\"]*)") (?:was|am|is) "([^\"]*)" (?:at|to|for) (?:the|that) event(?:\s"([^\"]*)")? as (?:a|an) "([^\"]*)"$'
Given /#{rostering_regex}/ do |full_name, state, event_name, role_name|
  staff = full_name ? Staff.find_by_full_name!(full_name) : @current_staff
  state = Rostering::States[state.to_sym]
  @event = event_name ? find_or_create_event(event_name) : @event
  find_or_create_role(role_name)
  assert staff.roster_to(@event, @role, true, :state => state)
end

Given /^(?:I|"([^\"]*)") (?:am|is) not rostered to anything$/ do |full_name|
  staff = full_name ? Staff.find_by_full_name!(full_name) : @current_staff
  staff.rosterings.delete_all
end

When /^I update roles to require (\d+) "([^\"]*)"(\swithout auto rostering)?$/ do |amount, role_name, no_auto_roster|
  if no_auto_roster
    find_or_create_role(role_name)
    @event.roles[@role.id.to_s] = amount.to_s
    Event.update_all(:roles => @event.roles.to_yaml, :id => @event.id)
  else
    And "I fill in \"#{role_name}\" with \"#{amount}\""
    And 'I press "event_submit"'
    Then 'I should see "Event was successfully updated."'
  end
end

When /^I finalize that events roster$/ do
  When 'I press "Finalize Roster for this Event"'
end

When /^I approve "([^\"]*)" as an "([^\"]*)" at the event$/ do |full_name, role_name|
  When 'I go to view the event'
  And "I update roles to require 1 \"#{role_name}\""
  When "I follow \"approve\" within \".selected_staff .#{role_name.downcase.gsub(/\s/, '_')}\""
  Then "I should see \"#{full_name} has been approved as a #{role_name} at this event.\""
end

When /^I manually add "([^\"]*)" as an "([^\"]*)" at the event$/ do |full_name, role_name|
  When "I update roles to require 1 \"#{role_name}\" without auto rostering"
  And 'I go to view the event'
  And "I follow \"add\" within \".selected_staff .#{role_name.downcase.gsub(/\s/, '_')}\""
  Then 'I should see "Search for member to roster"'
  And "I should see \"#{full_name}\""

  When "I follow \"#{full_name}\""
  Then "I should see \"#{full_name} has been added as a #{role_name} to this event.\""
  And "I should see \"(1/1)\" within \".selected_staff .#{role_name.downcase.gsub(/\s/, '_')}\""
  And "I should see \"#{full_name}\" within \".selected_staff .#{role_name.downcase.gsub(/\s/, '_')}\""
end

Then /^"([^\"]*)" should receive an email containing details about their new rostering$/ do |full_name|
  Then "the staff member \"#{full_name}\" should receive an email"
  When 'they open the email'
  Then 'they should see /You have been scheduled to work at a new event/ in the email subject'
  And 'they should see "accept or decline this event by visiting your dashboard" in the email body'
end

Then /^the rostering for "([^\"]*)" at the event should be "([^\"]*)"(\sby the system)?$/ do |full_name, state, by_system|
  staff = Staff.find_by_full_name!(full_name)
  rostering = staff.rosterings_at(@event).first
  assert rostering.declined?
  assert rostering.system_flagged? if by_system
end
