When /^I fill in event details for "([^\"]*)" at "([^\"]*)"$/ do |event_name, event_venue|
  step "I fill in \"Name\" with \"#{event_name}\""
  step "I select \"#{event_venue}\" from \"Venue\""
  step 'the event starts 1 day from now'
  step 'the event ends 2 days from now'
end

When /^the event (starts|ends) ([^\"]*)$/ do |type, time|
  fill_in_datetime_with(parse_time(time), "event_#{type.singularize}_datetime")
end

Given /^(?:an|a)(?:\s([^\s]*))? event "([^\"]*)" exists at "([^\"]*)"$/ do |state, event_name, event_venue|
  state ||= 'working'
  approver_id = (state == 'approved' ? Staff.first.id : nil)
  find_or_create_venue(event_venue)
  find_or_create_event(event_name, :venue_id => @venue.id, :state => Event::States[state.to_sym], :approver_id => approver_id)
end

Given /^that event has not started$/ do
  # do nothing, find_or_create_event makes events that have not started
end

Given /^that event starts in ([^\"]*)$/ do |time|
  reload_event
  time = parse_time(time)
  @event.update_attributes!({
    :start_datetime => time,
    :end_datetime => time + 1.day,
    :allow_past_events => true,
    :ignore_event_conflicts => true
  })
end

Given /^that event ends in ([^\"]*)$/ do |time|
  reload_event
  time = parse_time(time)
  @event.update_attributes!({
    :end_datetime => time,
    :allow_past_events => true,
    :ignore_event_conflicts => true
  })
end

Given /^that event is in progress$/ do
  reload_event
  @event.update_attributes!({
    :start_datetime => 1.day.ago,
    :end_datetime => 1.day.from_now,
    :allow_past_events => true
  })
end

Given /^that event finished ([^\"]*)$/ do |time|
  reload_event
  time = parse_time(time)
  @event.update_attributes!({
    :start_datetime => (time - 1.minute),
    :end_datetime => time,
    :allow_past_events => true
  })
end

Given /^that events state is ([^\"]*)$/ do |event_is|
  reload_event
  @event.approver_id = Staff.first.id if event_is == 'approved'
  @event.send("#{Event::States[event_is.to_sym]}!")
end

Given /^that event is deleted$/ do
  reload_event
  @event.destroy(false)
end

When /^I check mass confirm box for "([^\"]*)"$/ do |event_name|
  event = Event.find_by_name!(event_name)
  check("approve_event_ids_#{event.id}")
end

When /^I cancel the event$/ do
  reload_event
  @event.cancel
end

When /^I contact "([^\"]*)" about "([^\"]*)" and "([^\"]*)"$/ do |staff_type, message_subject, message_body|
  @email_subject = "contacted you regarding the event"
  @message_subject, @message_body = message_subject, message_body

  step "I go to view the event"
  step 'I follow "Contact Staff Involved"'
  step "I select \"#{staff_type}\" from \"group\""
  step "I fill in \"Subject\" with \"#{@message_subject}\""
  step "I fill in \"Email body\" with \"#{@message_body}\""
  step 'I press "Send Email"'
end

Then /^the event should have the error "([^\"]*)"$/ do |error|
  reload_event
  @event.errors.full_messages.include?(error)
end

private

# We need to reload any changes incase we made changes via webrat
# We also need to do it within an exclusive scope for cancelled/deleted events
def reload_event
  Event.with_exclusive_scope { @event.reload }
end
