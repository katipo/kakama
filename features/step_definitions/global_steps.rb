Given /^administrators get all emails$/ do
  Setting.update({ :administrators_get_special_emails => true }, false)
end

Given /^administrators dont get all emails$/ do
  Setting.update({ :administrators_get_special_emails => false }, false)
end

Then /^all administrators should receive ([^\"]*) email$/ do |amount|
  Setting.site_administrator_emails.each do |admin_email|
    Then "\"#{admin_email}\" should receive #{amount} email"
  end
end

private

# Takes a string and parses it into a time object via Rails time extensions
def parse_time(time)
  return Time.parse(time) if time =~ /^\d{4}-\d{2}-\d{2}$/ # dates like 2009-08-31
  return Time.now if %w{ today now }.include?(time)
  time.gsub!('from now', 'from_now') if time.include?('from now') # "1 day from now" -> "1 day from_now"
  eval(time.split.join('.')) # "1 day from_now" -> eval("1.day.from_now")
rescue
  nil
end

# Method for filling in datetime select boxes provided by Rails
def fill_in_datetime_with(time, id, date_only = false)
  raise "ERROR: fill_in_datetime_with expected a Time abject, but got a #{time.class.name}." unless time.is_a?(Time)
  select(time.year, :from => "#{id}_1i")              # year
  select(time.strftime('%B'), :from => "#{id}_2i")    # month
  select(time.day, :from => "#{id}_3i")               # day
  unless date_only
    select(time.hour.to_two_digit, :from => "#{id}_4i") # hour
    select(time.min.to_two_digit, :from => "#{id}_5i")  # minute
  end
end
