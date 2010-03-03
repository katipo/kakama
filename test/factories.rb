require 'factory_girl'

#
# Staff
#

# full name is passed in when the factory is made
Factory.define :staff do |s|
  s.full_name { "Joe#{(rand*10000).to_i} Someone" }
  s.username { |u| u.full_name.split.first.downcase }
  s.staff_type 'staff'
  s.password 'test'
  s.password_confirmation 'test'
  s.start_date Time.new.strftime('%Y-%m-%d')
  s.email { |u| u.full_name.split.first.downcase + "@example.com" }
end

def find_or_create_staff(full_name, options = {})
  @staff = Staff.find_by_full_name(full_name)
  if @staff.nil?
    options[:full_name] = full_name
    @staff = Factory(:staff, options)
    assert_kind_of Staff, @staff
  else
    @staff.update_attributes!(options)
  end
  @staff
end

#
# Venue
#

Factory.define :venue do |v|
  v.name 'Some Venue'
end

def find_or_create_venue(name, options = {})
  @venue = Venue.find_by_name(name)
  if @venue.nil?
    options[:name] = name
    @venue = Factory(:venue, options)
    assert_kind_of Venue, @venue
  else
    @venue.update_attributes!(options)
  end
  @venue
end

#
# Event
#

Factory.define :event do |e|
  e.name 'Some Event'
  e.start_datetime 1.day.from_now
  e.end_datetime 4.days.from_now
  e.association :venue, :factory => :venue
  e.association :organiser, :factory => :staff
end

def find_or_create_event(name, options = {})
  @event = Event.find_by_name(name)
  if @event.nil?
    options[:name] = name
    @event = Factory(:event, options)
    assert_kind_of Event, @event
  else
    @event.update_attributes!(options)
  end
  @event
end

#
# Role
#

Factory.define :role do |r|
  r.name 'Some Role'
end

def find_or_create_role(name, options = {})
  @role = Role.find_by_name(name)
  if @role.nil?
    options[:name] = name
    @role = Factory(:role, options)
    assert_kind_of Role, @role
  else
    @role.update_attributes!(options)
  end
  @role
end
