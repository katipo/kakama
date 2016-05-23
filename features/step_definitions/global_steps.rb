Given /^administrators get all emails$/ do
  Setting.update({ :administrators_get_special_emails => true }, false)
end

Given /^administrators dont get all emails$/ do
  Setting.update({ :administrators_get_special_emails => false }, false)
end

Then /^all administrators should receive ([^\"]*) emails?$/ do |amount|
  Setting.site_administrator_emails.each do |admin_email|
    step "\"#{admin_email}\" should receive #{amount} email"
  end
end

Then /^show me the unread emails for "([^\"]*)"$/ do |email_or_full_name|
  unread_emails_for(parse_email(email_or_full_name)).each { |e| puts "\n#{e.subject.inspect}\n#{e.body.inspect}\n\n" }
end

Then /^show me the email inbox for "([^\"]*)"$/ do |full_name|
  mailbox_for(parse_email(email_or_full_name)).each { |e| puts "\n#{e.subject.inspect}\n#{e.body.inspect}\n\n" }
end

Given /^it is currently (.+)$/ do |time|
  Timecop.travel(parse_time(time))
end

Given /^(?:I|we) return to the present$/ do
  Timecop.return
end

Given /^all delayed jobs have run$/ do
  Delayed::Job.work_off
end

private

# Takes a string and parses it into a time object via Rails time extensions
def parse_time(time)
  # return Time.parse(time) if time =~ /^\d{4}-\d{2}-\d{2}$/ # dates like 2009-08-31
  # return Time.now if %w{ today now }.include?(time)
  # time.gsub!('from now', 'from_now') if time.include?('from now') # "1 day from now" -> "1 day from_now"
  # eval(time.split.join('.')) # "1 day from_now" -> eval("1.day.from_now")
  Chronic.parse(time)
rescue
  nil
end

# Takes either an email or a staff name and converts it into an email string
def parse_email(email_or_full_name)
  if email_or_full_name =~ /@/
    email_or_full_name
  else
    staff = Staff.find_by_full_name!(full_name)
    raise "#{full_name} has no email, thus no unread emails to show." if staff.email.blank?
    staff.email
  end
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
