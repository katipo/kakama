Given /^(?:I|"([^\"]*)") (?:am|is) (also|only|) *available from ([^\"]*) till ([^\"]*)$/ do |full_name, exclusivity, start_date, end_date|
  staff = full_name ? Staff.find_by_full_name!(full_name) : @current_staff
  start_date, end_date = parse_time(start_date), parse_time(end_date)

  Availability.delete(staff.availability.collect {|x| x.id}) if exclusivity == :only

  staff.availability << Availability.create!(
    :staff_id => staff.id,
    :start_date => start_date,
    :end_date => end_date,
    :hours => {
      :all => { :start => 0, :finish => 24 }
    }
  )
  staff.availability
end

When /^I mark ([^\"]*) till ([^\"]*) as available$/ do |start_date, end_date|
  fill_in 'availability_start_date', with: start_date
  fill_in 'availability_end_date', with: end_date
end

When /^I click on one of the conflicting availabilities$/ do
  # TODO: find a better way to select the first link!
  # TODO: find a way to select x link of the conflicts
  click_link "availability_conflict_0"
end

When /^I split (my current\s)?availability (\d+\s)?at ([^\"]*)$/ do |current, position, split_date|
  if !current.blank?
    When "I go to split my current availability"
  else
    visit split_staff_availability_path(:current, current_staff_availability[position.to_i - 1])
  end
  split_date = parse_time(split_date)
  fill_in_datetime_with split_date, 'availability_split_date', true
  And "I press \"Split Availability\""
end

When /^I delete availability (\d+)$/ do |position|
  availability = current_staff_availability[position.to_i - 1]
  availability.destroy
end

Then /^I should have (\d+) availabilit(?:y|ies)$/ do |amount|
  @current_staff.reload
  @current_staff.availability.size.should == amount.to_i
end

def current_staff_availability
  @current_staff.availability.find(:all, :order => 'start_date ASC')
end

Then /^availability (\d+) should be from ([^\"]*) till ([^\"]*)$/ do |position, start_date, end_date|
  availability = current_staff_availability[position.to_i - 1]
  availability.start_date.should == parse_time(start_date).to_date
  availability.end_date.should == parse_time(end_date).to_date
end
