require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @venue = find_or_create_venue 'Custom Venue'
    @event = find_or_create_event 'Event 1', { :name => 'Event 1', :venue_id => @venue.id }
  end

  test "conflicts_with_another_event is correctly finding events that conflict" do
    options = { :name => 'Event 1', :venue_id => @venue.id }

    should_not_conflict options.merge(:start_datetime => 1.minute.from_now, :end_datetime => 2.minutes.from_now)
    should_not_conflict options.merge(:start_datetime => 5.days.from_now, :end_datetime => 6.days.from_now)

    should_conflict options.merge(:start_datetime => 1.minute.from_now, :end_datetime => @event.start_datetime)
    should_conflict options.merge(:start_datetime => 1.minute.from_now, :end_datetime => 2.days.from_now)
    should_conflict options.merge(:start_datetime => @event.start_datetime, :end_datetime => 2.days.from_now)
    should_conflict options.merge(:start_datetime => 2.days.from_now, :end_datetime => 3.days.from_now)
    should_conflict options.merge(:start_datetime => 3.days.from_now, :end_datetime => @event.end_datetime)
    should_conflict options.merge(:start_datetime => 3.days.from_now, :end_datetime => 5.days.from_now)
    should_conflict options.merge(:start_datetime => @event.end_datetime, :end_datetime => 5.days.from_now)
    should_conflict options.merge(:start_datetime => 1.minute.from_now, :end_datetime => 5.days.from_now)
  end

  test "states have boolean methods associated with them" do
    @event.update_attribute(:state, Event::States[:working])
    assert @event.working?
    assert !@event.approved?
    assert !@event.cancelled?

    @event.update_attribute(:state, Event::States[:approved])
    assert !@event.working?
    assert @event.approved?
    assert !@event.cancelled?

    @event.update_attribute(:state, Event::States[:cancelled])
    assert !@event.working?
    assert !@event.approved?
    assert @event.cancelled?
  end

  test "passed_cut_off_date? is correctly marking events that have passed the cut off date" do
    cutoff = Setting.event_cut_off

    @event.update_attribute(:start_datetime, cutoff.days.from_now + 1.minute)
    assert !@event.passed_cut_off_date?

    @event.update_attribute(:start_datetime, cutoff.days.from_now - 1.minute)
    assert @event.passed_cut_off_date?
  end

  test "time_response_required_by is correctly indicating remaining response time" do
    cutoff = Setting.event_cut_off
    response_time = Setting.response_time

    @event.update_attribute(:start_datetime, 1.day.from_now)
    assert_equal false, @event.time_response_required_by

    extra_time = 1.day.from_now
    @event.update_attribute(:start_datetime, (extra_time + cutoff.days))
    assert_equal extra_time.to_s, @event.time_response_required_by.to_s

    @event.update_attribute(:start_datetime, (cutoff.days.from_now + 6.days))
    assert_equal response_time.days.from_now.to_s, @event.time_response_required_by.to_s
  end

  private

  def should_not_conflict(options)
    assert !Event.new(options).conflicts_with_another_event?
  end

  def should_conflict(options)
    assert Event.new(options).conflicts_with_another_event?
  end
end
