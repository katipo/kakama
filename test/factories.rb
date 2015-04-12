require 'factory_girl'

#
# Staff
#

# full name is passed in when the factory is made
FactoryGirl.define do
  factory :staff do 
    full_name { "Joe#{(rand*10000).to_i} Someone" }
    username { |u| u.full_name.split.first.downcase }
    staff_type 'staff'
    password 'test'
    password_confirmation 'test'
    start_date Time.new.strftime('%Y-%m-%d')
    email { |u| u.full_name.split.first.downcase + "@example.com" }
  end
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
# Availability
#
FactoryGirl.define do
  factory :availability do 
    staff_id 1
    start_date 10.days.ago
    end_date 2.years.from_now
  end
end

#
# Venue
#
FactoryGirl.define do
  factory :venue do |v|
    v.name 'Some Venue'
  end
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
FactoryGirl.define do
  factory :event do |e|
    e.name 'Some Event'
    e.start_datetime 1.day.from_now
    e.end_datetime 4.days.from_now
    e.association :venue, :factory => :venue
    e.association :organiser, :factory => :staff
  end
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
FactoryGirl.define do
  factory :role do |r|
    r.name 'Some Role'
  end
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
