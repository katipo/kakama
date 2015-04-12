# == Schema Information
#
# Table name: availabilities
#
#  id           :integer          not null, primary key
#  staff_id     :integer          not null
#  start_date   :date             not null
#  end_date     :date             not null
#  hours        :text             not null
#  admin_locked :boolean
#  created_at   :datetime
#  updated_at   :datetime
#

class Availability < ActiveRecord::Base
  belongs_to :staff

  validates_presence_of :staff_id, :start_date, :end_date

  before_validation :convert_all_values

  after_save :notify_correct_people_of_changes
  before_update :ensure_availability_changeable

  attr_accessor :ignore_availability_conflicts, :notification_comment,
                :edited_by_administrator, :changing_own_availability,
                :split_date

  serialize :hours

  Days = [
    [:mon, 'Monday'],
    [:tue, 'Tuesday'],
    [:wed, 'Wednesday'],
    [:thu, 'Thursday'],
    [:fri, 'Friday'],
    [:sat, 'Saturday'],
    [:sun, 'Sunday']
  ]

  scope :overlapping, lambda { |start_date, end_date| { :conditions => [
    "(:start_date >= availabilities.start_date AND :start_date <= availabilities.end_date) OR
     (:end_date >= availabilities.start_date AND :end_date <= availabilities.end_date) OR
     (availabilities.start_date >= :start_date AND availabilities.start_date <= :end_date) OR
     (availabilities.end_date >= :start_date AND availabilities.end_date <= :end_date)".squish,
    { :start_date => start_date.to_date.to_s, :end_date => end_date.to_date.to_s }
  ] } }

  scope :wrapping, lambda { |start_date, end_date| { :conditions => [
    "(availabilities.start_date <= :start_date AND availabilities.end_date >= :end_date)",
    { :start_date => start_date.to_date.to_s, :end_date => end_date.to_date.to_s }
  ] } }

  # WARNING
  # Split day event availability detection is still incomplete
  # and can select people who aren't availabile all hours, as
  # the current system checks start/end hours, not ones between
  # TODO: Improve/expand this code and add to the corresponding
  # test suite as needed
  # TODO: Add support for overlapping hours that make up enough
  # time for work at an event (9am-12pm and 11am-5pm for example)
  def self.with_hours_of(event)
    start_day, start_hour = event.start_datetime.strftime("%a").downcase.to_sym, event.start_datetime.hour
    end_day, end_hour = event.end_datetime.strftime("%a").downcase.to_sym, event.end_datetime.hour

    all.select do |availability|
      hours = availability.hours
      next if hours.blank? || hours[start_day].blank? || hours[end_day].blank?
      if start_day == end_day
        next if !hours[start_day].any? { |t| start_hour.to_i >= t[:start].to_i && end_hour.to_i <= t[:finish].to_i }
      else
        # TODO: Make this more advanced. Need some way to figure out when the event ends each day of the end (4pm? 10pm?)
        next if !hours[start_day].any? { |t| start_hour.to_i >= t[:start].to_i && start_hour.to_i <= t[:finish].to_i }
        next if !hours[end_day].any? { |t| end_hour.to_i >= t[:start].to_i && end_hour.to_i <= t[:finish].to_i }
      end
      true
    end
  end

  def self.within_hours_of?(event)
    self.with_hours_of(event).size > 0
  end

  # Gets an array of Times objects (see the class at the bottom of this file)
  # This is used for the weekly builder. Has only starts_at, ends_at, and comment
  # First argument is when to start counting time objects. By default, it starts
  # from the beginning of the availability, but the weekly_builder calender passes
  # the current week start date into it which restricts lookup to the viewed week
  # The second argument overides the first. If true, all time object between the
  # start and end of the availability are collected (can be quite slow for long
  # periods of availability)
  def times(now = start_date, return_all = false)
    if return_all
      range = (start_date..end_date)
    else
      week_start, week_end = now.beginning_of_week.to_date, now.end_of_week.to_date
      range = (week_start..week_end).reject { |d| d < start_date || d > end_date }
    end

    time_objects = Array.new
    range.each do |date|
      values = hours[date.strftime('%a').downcase.to_sym]
      next if values.blank?
      values.each do |data|
        next if data[:start].blank? || data[:finish].blank?
        time_objects << Times.new(
          :starts_at => Chronic.parse("#{date} #{data[:start].to_two_digit}:00"),
          :ends_at => Chronic.parse("#{date} #{data[:finish].to_two_digit}:00"),
          :comment => data[:comment]
        )
      end
    end

    time_objects.compact
  end

  def other_availabilities_overlapping_this_time
    return Array.new unless staff && start_date && end_date
    staff.availabilities_overlapping(start_date, end_date).reject { |a| a == self }
  end

  def conflicts_with_another_availability?
    other_availabilities_overlapping_this_time.size > 0
  end

  def events_rostered_at_this_time?
    staff.events.between(Chronic.parse(start_date), Chronic.parse(end_date).end_of_day).size > 0
  end

  def split_at(params)
    if !params[:split_date].blank?
      # In most cases, people have Javascript turned on, and it returns a string for parsing
      split_date = Time.parse(params[:split_date])
    else
      # However, when Javascript is off, rails date selectors send weird data
      date = [params['split_date(1i)'], params['split_date(2i)'], params['split_date(3i)']].join('-')
      split_date = Chronic.parse(date)
    end

    if split_date.blank?
      errors.add_to_base("You left the split date empty. You must supply one.")
      false
    elsif split_date <= start_date
      errors.add_to_base("The split date must be after this availabilities start date.")
      false
    elsif split_date > end_date
      errors.add_to_base("The split date must be on or before this availabilities end date.")
      false
    elsif staff.events.occuring_at(split_date, split_date).size > 0
      errors.add_to_base("You cannot split your availability here because there are events overlapping it.")
      false
    else
      new_availability = self.clone
      new_availability.start_date = split_date.to_date.to_s
      # Ignore conflicts because we're saving on top of the other one before we edit it
      new_availability.ignore_availability_conflicts = true
      # Update wont raise add_to_base errors properly, so raise the first one manually
      new_availability.save! rescue raise errors.full_messages.first

      self.end_date = (split_date - 1.day).to_date.to_s
      # Ignore conflicts because a before filter disabled editing if events are within a
      # time slot but we've already done our own checking, so we should be safe doing this
      self.ignore_availability_conflicts = true
      # Update wont raise add_to_base errors properly, so raise the first one manually
      self.save! rescue raise errors.full_messages.first

      true
    end
  end

  private

  # Loop through hour values. If they 'all' value is present, set it.
  # If 'all' is not set but the hour is, convert to an integer, else
  # set it to nil
  def convert_all_values
    self.start_date = start_date.to_date if start_date.is_a?(Time)
    self.end_date = end_date.to_date if end_date.is_a?(Time)
    self.hours = Hash.new unless hours.class.name =~ /Hash/

    all = hours.delete(:all) || Hash.new
    Availability::Days.each do |key, value|
      hours[key] ||= [ { :start => nil, :finish => nil, :comment => nil } ]
      raise "ERROR: Expected an Array but got a #{hours[key].class.name}" unless hours[key].is_a?(Array)
      hours[key].each do |data|
        raise "ERROR: Expected a Hash but got a #{data.class.name}" unless hours.class.name =~ /Hash/
        [:start, :finish].each do |time|
          data[time] = if !all[time].blank?
            all[time].to_i
          elsif !data[time].blank?
            data[time].to_i
          else
            nil
          end
        end
      end
    end
  end

  def notify_correct_people_of_changes
    return if changing_own_availability && edited_by_administrator
    recipient = edited_by_administrator ? staff : Setting.site_administrator_emails
    return if notification_comment.blank? || recipient.blank? || (recipient.is_a?(Staff) && recipient.email.blank?)
    Notifier.availability_changes_notification(recipient, self).deliver
  end

  def ensure_availability_changeable
    if !ignore_availability_conflicts && events_rostered_at_this_time?
      errors.add_to_base("You can't edit this availability because you are rostered to an event at this time.")
      false
    else
      true
    end
  end

  protected

  # to pass validations:
  #  - end_date must be after start_date
  #  - no conflicts can be found unless that check is overidden
  #  - if hours are set, the finishing hour must come after the starting hour
  def validate
    passes_validation = true
    if start_date && end_date
      if end_date < start_date
        errors.add(:end_date, "must be set to a date on or after the start date.")
        passes_validation = false
      end
    end
    if !ignore_availability_conflicts && conflicts_with_another_availability?
      errors.add_to_base("The availability you're trying to add conflicts with an already existing availability.")
    end
    if hours
      Availability::Days.each do |key, label|
        next if hours[key].blank?
        hours[key].each do |data|
          next if data.blank? || data[:start].blank? # we dont have to set a time for every day
          if data[:finish].to_i <= data[:start].to_i
            errors.add(:hours, "for a timeslot on #{label} must have finishing time after starting time.")
            passes_validation = false
          end
        end
      end
    end
    passes_validation
  end
end

class Times
  attr_accessor :starts_at, :ends_at, :comment
  def initialize(options)
    self.starts_at = options[:starts_at]
    self.ends_at = options[:ends_at]
    self.comment = options[:comment]
  end
end
