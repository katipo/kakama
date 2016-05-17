Given /^a venue "([^\"]*)" exists$/ do |name|
  find_or_create_venue(name)
end

Given /^that venue has (past|future) events$/ do |type|
  options = { :name => 'Event', :venue_id => @venue.id, :organiser_id => @current_staff.id }
  if type == 'past'
    options.merge!(:start_datetime => 2.day.ago, :end_datetime => 1.days.ago, :allow_past_events => true)
  else
    options.merge!(:start_datetime => 1.day.from_now, :end_datetime => 2.days.from_now)
  end
  find_or_create_event(options[:name], options)
end

When /^I try to delete the venue, I should be refused to access the record$/ do
  visit delete_venue_path(@venue)
  expect(page).to have_content('Are you sure you want to delete ?')
  click_button('Delete')
  expect(page).to have_content('You cannot delete this venue because it contains unfinished events.')
end

Then /^the venues select field should be set to "([^\"]*)"$/ do |venue_name|
  field_labeled('Venue').value.should == @venue.id.to_s
end
