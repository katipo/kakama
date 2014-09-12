require 'test_helper'

class AvailabilityTest < ActiveSupport::TestCase
  def setup
    @sally = find_or_create_staff('Sally')
    @sally.availability.create!(:start_date => Time.now, :end_date => 3.days.from_now)
    @sally.availability.create!(:start_date => 6.days.from_now, :end_date => 7.days.from_now)

    @event = find_or_create_event('Big Concert',
      :start_datetime => cp("tomorrow 9am"),
      :end_datetime => cp("tomorrow 5pm")
    )

    @availabilities = @sally.availability.overlapping(@event.start_datetime, @event.end_datetime)
  end

  test "named scope overlapping is returning results before, after, overlapping, around or between two dates" do
    assert_equal 0, @sally.availability.overlapping(2.days.ago, 1.day.ago).size
    assert_equal 1, @sally.availability.overlapping(1.days.ago, Time.now).size
    assert_equal 1, @sally.availability.overlapping(1.days.ago, 1.day.from_now).size
    assert_equal 1, @sally.availability.overlapping(Time.now, 1.day.from_now).size
    assert_equal 1, @sally.availability.overlapping(1.day.from_now, 2.days.from_now).size
    assert_equal 1, @sally.availability.overlapping(2.days.from_now, 3.days.from_now).size
    assert_equal 1, @sally.availability.overlapping(2.days.from_now, 4.days.from_now).size
    assert_equal 1, @sally.availability.overlapping(3.days.from_now, 4.day.from_now).size
    assert_equal 0, @sally.availability.overlapping(4.days.from_now, 5.days.from_now).size
    assert_equal 2, @sally.availability.overlapping(2.days.ago, 8.days.from_now).size
  end

  test "named scope wrapping is returning results that are fully wrapped between two dates" do
    assert_equal 0, @sally.availability.wrapping(2.days.ago, 1.day.ago).size
    assert_equal 0, @sally.availability.wrapping(1.days.ago, Time.now).size
    assert_equal 0, @sally.availability.wrapping(1.days.ago, 1.day.from_now).size
    assert_equal 1, @sally.availability.wrapping(Time.now, 1.day.from_now).size
    assert_equal 1, @sally.availability.wrapping(1.day.from_now, 2.days.from_now).size
    assert_equal 1, @sally.availability.wrapping(2.days.from_now, 3.days.from_now).size
    assert_equal 0, @sally.availability.wrapping(2.days.from_now, 4.days.from_now).size
    assert_equal 0, @sally.availability.wrapping(3.days.from_now, 4.day.from_now).size
    assert_equal 0, @sally.availability.wrapping(4.days.from_now, 5.days.from_now).size
    assert_equal 0, @sally.availability.wrapping(2.days.ago, 8.days.from_now).size
  end

  test "times is returning valid Time object as weekly_builder plugin expects" do
    first_monday = Chronic.parse('First Monday this year')
    availability = @sally.availability.create!(:start_date => first_monday, :end_date => first_monday + 20.days)

    assert_equal 0, availability.times.size # no hours have been set at this stage

    availability.update_attributes(:hours => { :mon => [{ :start => 9, :finish => 17 }] })
    assert_equal 1, availability.times.size
    assert_equal 1, availability.times(first_monday + 10.days).size
    assert_equal 3, availability.times(nil, true).size
  end

  test "conflicts_with_another_availability? is returning correct result" do
    assert !@sally.availability.new.conflicts_with_another_availability?
    assert !@sally.availability.new(:start_date => 10.days.from_now, :end_date => 11.days.from_now).conflicts_with_another_availability?
    assert @sally.availability.new(:start_date => 1.days.from_now, :end_date => 3.days.from_now).conflicts_with_another_availability?

    @sally.availability.create!(:start_date => 10.days.from_now, :end_date => 11.days.from_now)
    availability = sally_availabilities.last
    assert !availability.conflicts_with_another_availability?
  end

  def sally_availabilities
    @sally.availability.find(:all, :order => 'start_date ASC')
  end

  test "assigning hours via all settings works as expected" do
    # Avoid picking up the wrong record at the end of the test
    if sally_availabilities().find_by_start_date(6.days.from_now)
      sally_availabilities().find_by_start_date(6.days.from_now).destroy
    end

    sally_availabilities().first.update_attributes(:hours => { :all => { :start => 0, :finish => 24 } })

    expected = {}
    Availability::Days.each { |key, label| expected[key] = [{:finish=>24, :start=>0, :comment=>nil}] }
    assert_equal expected, sally_availabilities.first.hours
  end

  test "with_hours_of and within_hours_of? are returning correct results" do
    # Remove the test record that doesn't apply to this test and was interfering with results
    if @sally.availability.find_by_start_date(6.days.from_now)
      @sally.availability.find_by_start_date(6.days.from_now).destroy
    end

    # One availability block on the day
    every_day_has([{ :start => 9, :finish => 17 }])
    test_availabilities_with([
      ['7am', '8am', 0], ['8am', '9am', 0], ['8am', '10am', 0],
      ['9am', '10am', 1], ['10am', '4pm', 1], ['9am', '5pm', 1], ['4pm', '5pm', 1],
      ['4pm', '6pm', 0], ['5pm', '6pm', 0], ['6pm', '7pm', 0]
    ])

    # Different availabilities on the same day (9am-11am and 2pm-5pm).
    every_day_has([{ :start => 9, :finish => 11 }, { :start => 14, :finish => 17 }])
    test_availabilities_with([
      ['7am', '8am', 0], ['8am', '9am', 0], ['8am', '10am', 0],
      ['9am', '10am', 1], ['10am', '4pm', 0], ['9am', '5pm', 0], ['4pm', '5pm', 1],
      ['4pm', '6pm', 0], ['5pm', '6pm', 0], ['6pm', '7pm', 0]
    ])

    # TODO: Actually make this work. Budget doesn't allow for this yet
    # Overlapping availabilities on the same day (9am-12pm and 11am-17pm)
    # every_day_has([{ :start => 9, :finish => 12 }, { :start => 11, :finish => 17 }])
    # test_availabilities_with([
    #   ['7am', '8am', 0], ['8am', '9am', 0], ['8am', '10am', 0],
    #   ['9am', '10am', 1], ['10am', '4pm', 1], ['9am', '5pm', 1], ['4pm', '5pm', 1],
    #   ['4pm', '6pm', 0], ['5pm', '6pm', 0], ['6pm', '7pm', 0]
    # ])

    # WARNING
    # Split day event availability detection is still incomplete
    # and can select people who aren't availabile all hours, as
    # the current system checks start/end hours, not ones between
    # TODO: Improve/expand these tests and make the corresponding
    # model code work as needed

    # split day events (normal hours)
    @event.update_attributes(
      :start_datetime => cp("tomorrow 9am"),
      :end_datetime => cp("tomorrow 5pm") + 1.day
    )
    assert_equal 1, @availabilities.with_hours_of(@event).size
    assert_equal true, @availabilities.within_hours_of?(@event)

    # split day events (over night)
    @event.update_attributes(
      :start_datetime => cp("tomorrow 9pm"),
      :end_datetime => cp("tomorrow 4am") + 1.day
    )
    sally_availabilities.first.update_attributes(:hours => {
      @event.start_datetime.strftime("%a").downcase.to_sym => [{ :start => 17, :finish => 24 }],
      @event.end_datetime.strftime("%a").downcase.to_sym => [{ :start => 0, :finish => 9 }]
    })
    assert_equal 1, @availabilities.with_hours_of(@event).size
    assert_equal true, @availabilities.within_hours_of?(@event)
  end

  private

  def cp(time)
    Chronic.parse("#{time}")
  end

  def every_day_has(data)
    hours = Hash.new
    Availability::Days.each { |key, label| hours[key] = data }
    sally_availabilities.first.update_attributes(:hours => hours)
  end

  def test_availabilities_with(data)
    data.each do |start_time, end_time, amount_expected|
      @event.update_attributes(
        :start_datetime => cp("tomorrow #{start_time}"),
        :end_datetime => cp("tomorrow #{end_time}")
      )
      amount_available = @availabilities.with_hours_of(@event).size
      assert_equal amount_expected, amount_available,
                   "#{start_time}-#{end_time} expected #{amount_expected} availabilities with exact hours, got #{amount_available}"
      assert_equal (amount_expected > 0), @availabilities.within_hours_of?(@event)
    end
  end
end
