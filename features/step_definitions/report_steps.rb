When /^I click "(.*)"$/ do  | link_name |
  click_link link_name
end

Given /^(?:I|"([^\"]*)") (?:has|have) ([0-9]*) (no show|declined|)(?: |)(?:rosterings|rostering)(?: for the |)(?:"([^\"]*)"|)(.*)$/ do |full_name, rosterings_count,state,event_name,event_start|
  staff = full_name ? Staff.find_by_full_name!(full_name) : @current_staff
  state = state ? state.parameterize.underscore: 'approve'
  start = parse_time(event_start)
  options = start ? {:start_datetime => start, :end_datetime => (start + 1.days)} : {}
  name = event_name && event_name.length > 0 ? event_name : 'Big concert'

  @event = find_or_create_event(name, options)
  find_or_create_role("Usher")
  assert staff.roster_to(@event, @role, true, :state => state), "Unable to roster event to #{full_name}"
  @event
end