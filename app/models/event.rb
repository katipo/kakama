class Event < ActiveRecord::Base
  has_many :rosterings, :dependent => :destroy
  has_many :staff, :through => :rosterings
  has_many :email_logs, :dependent => :destroy
  belongs_to :venue
  has_one :schedule
  belongs_to :organiser, :class_name => "Staff", :foreign_key => "organiser_id"
  belongs_to :approver, :class_name => "Staff", :foreign_key => "approver_id"

  validates_presence_of :venue_id, :name, :start_datetime, :end_datetime, :organiser_id
  # TODO: Implement this if budget permits
  # validates_presence_of :recurring, :schedule_id

  before_create :set_state
  before_create :set_schedule_id
  before_create :set_roles
  before_update :check_approver_set_if_approving_roster
  before_update :store_changed_attributes
  before_update :ensure_staff_available_if_time_changed
  # Cancel unavailable staff first, so they don't get emails
  # in the next few callbacks that they don't need to know about
  after_update :cancel_unavailable_staff_if_requested
  # Send emails to those needing them, regarding name change
  after_update :email_staff_if_name_changed
  # Send emails to those needing them, regarding time changes
  after_update :email_staff_if_time_changed
  # Run this after the canceling, and emailing of name/time changes so
  # new staff don't get emails about things they don't need to know about
  after_update :select_staff_to_fill_roles
  # After all staff members have been cancelled, and roles filled in their places
  # email all staff if the event is going from working to approved state
  after_update :email_staff_involved_if_approved
  before_destroy :ensure_event_deletable

  # allow_past_events is used only in tests, and should not be allowed in production code!
  attr_accessor :allow_past_events
  # if there are conflicts of any type, should we ignore them? These include events
  # at the same venue and time, or unavailable staff after changing an event time.
  attr_accessor :ignore_event_conflicts
  # while the event is in a working state, if we change the role counts required, then
  # we should delete all unconfirmed rosterings so that we can effectively assign staff
  # to fill the roles required
  attr_accessor :clear_unconfirmed_rosterings
  # if there is unavailable staff, and the admin does not want to contact them manually
  # or cancel the entire event, then they can just cancel the unavailable staff, leaving
  # only the available ones. The remaining unfilled positions will then be refilled by
  # other staff members
  attr_accessor :cancel_unavailable_staff
  # USE SPARINGLY: when we approve the event, we may not want to notify each member
  # for each event this is the case with mass confirm. Instead, do everything else
  # but we'll handle the staff notification elsewhere.
  attr_accessor :skip_notification_email

  include SoftDelete

  serialize :roles

  States = {
    :working => 'working',
    :approved => 'approved',
    :cancelled => 'cancelled'
  }

  ContactGroups = [
    ['', ''],
    ['Unconfirmed Staff', 'unconfirmed'],
    ['Confirmed Staff', 'confirmed'],
    ['Unconfirmed and Confirmed Staff', 'unconfirmed_or_confirmed'],
    ['All (unconfirmed, confirmed, declined)', 'unconfirmed_or_confirmed_or_declined']
  ]

  default_scope :conditions => ['events.deleted_at IS ? AND events.state != ?', nil, Event::States[:cancelled]]

  scope :not_deleted, lambda { { :conditions => ['events.deleted_at IS ?', nil] } }
  scope :current, lambda { { :conditions => ['events.start_datetime <= :now AND events.end_datetime >= :now', { :now => Time.now.utc }], :order => "events.start_datetime ASC, events.end_datetime ASC" } }
  scope :future, lambda { { :conditions => ['events.start_datetime > ?', Time.now.utc], :order => "events.start_datetime ASC, events.end_datetime ASC" } }
  scope :current_or_future, lambda { { :conditions => ['events.end_datetime >= ?', Time.now.utc], :order => "events.start_datetime ASC, events.end_datetime ASC" } }
  scope :finished, lambda { { :conditions => ['events.end_datetime < ?', Time.now.utc], :order => "events.start_datetime DESC, events.end_datetime DESC" } }
  scope :finished_a_month_ago, lambda { { :conditions => ['events.end_datetime < ?', 1.month.ago.utc] } }
  scope :occuring_at, lambda { |start_datetime, end_datetime| { :conditions => [Event.sql_between_query, { :event_start => start_datetime.dup.utc, :event_end => end_datetime.dup.utc }] } }
  scope :between, lambda { |start_datetime, end_datetime| { :conditions => ['events.start_datetime >= :start_datetime AND events.end_datetime <= :end_datetime', { :start_datetime => start_datetime.dup.utc, :end_datetime => end_datetime.dup.utc }] } }
  scope :excluding, lambda { |excludes| excludes.blank? ? {} : { :conditions => ['events.id NOT IN (?)', excludes.collect { |e| e.id }] } }

  Event::States.each do |key,state_value|
    scope key, :conditions => { :state => state_value }
    define_method "#{key.to_s}?" do
      state == state_value
    end
    define_method "#{key.to_s}!" do
      # as well as setting the state, we also need to ensure we ignore any conflicts
      # all current cases where these methods are used do not need conflict checking
      values = {
        :state => state_value,
        :ignore_event_conflicts => true
      }
      # Update wont raise add_to_base errors properly, so raise the first one manually
      update_attributes!(values) rescue raise errors.full_messages.first
    end
  end

  %w{ rejected declined cancelled no_show }.each do |type|
    define_method "any_#{type}_staff?" do
      rosterings.send(type.to_sym).count > 0
    end
    define_method "#{type}_staff_for" do |role|
      rosterings.send(type.to_sym).with_role(role)
    end
  end

  # Gets run by a cron job after system reboot
  # and once every day (to fill up empty roles)
  def self.fill_all_empty_roles
    future.each { |e| e.select_staff_to_fill_roles }
  end

  # Create a method similar to destroy. Returns true if cancel worked, else false
  def cancel
    if cancelled?
      errors.add_to_base("Event has already been cancelled. You cannot cancel it twice.")
    elsif in_progress?
      errors.add_to_base("Event cannot be cancelled because it is in progress.")
      false
    elsif finished?
      errors.add_to_base("Event cannot be cancelled because it has already happened.")
      false
    else
      # We need to do this before cancelled! (when approved? is actually the right value)
      staff_to_contact = approved? ? rosterings.active_state : rosterings.confirmed
      cancelled!
      staff_to_contact.each do |rostering|
        rostering.skip_staff_selections_callback = true
        rostering.cancelled! # do not pass a reason to this method because we send out a different email below
        Notifier.deliver_email_or_pdf_of(:event_cancelled_notification, rostering.staff, self, rostering.role)
      end
      true
    end
  end

  def other_events_at_this_place_and_time
    # if we don't know what venue this event is at, don't ask for other events at a NULL venue
    return Array.new if venue_id.blank?

    options = { :venue_id => venue_id, :event_start => start_datetime, :event_end => end_datetime }
    sql = "venue_id = :venue_id AND (#{Event.sql_between_query})"

    unless new_record?
      options[:id] = id
      sql += " AND id != :id"
    end

    Event.all(:conditions => [sql, options])
  end

  def conflicts_with_another_event?
    other_events_at_this_place_and_time.size > 0
  end

  def not_started?
    start_datetime > Time.now
  end

  def started?
    !not_started?
  end

  def in_progress?
    start_datetime < Time.now &&
      end_datetime > Time.now
  end

  def finished?
    end_datetime < Time.now
  end

  def finished_a_month_ago?
    end_datetime < 1.month.ago
  end

  def editable?
    not_started? && !cancelled?
  end

  def cancelable?
    not_started? && !cancelled?
  end

  def deletable?
    cancelled? || finished_a_month_ago?
  end

  def deleted?
    deleted_at.present?
  end

  def amount_needed_for(role)
    roles[role.id.to_s].to_i
  end

  def filled_all_roles?
    filled_all_roles = true
    Role.all.each do |role|
      unless filled_spots_for?(role)
        filled_all_roles = false
        break
      end
    end
    filled_all_roles
  end

  def overfilled_any_roles?
    overfilled_any_roles = false
    Role.all.each do |role|
      if active_rosterings_for(role).size > amount_needed_for(role)
        overfilled_any_roles = true
        break
      end
    end
    overfilled_any_roles
  end

  def filled_spots_for?(role)
    active_rosterings_for(role).size >= amount_needed_for(role)
  end

  def active_rosterings_for(role)
    @active_rosterings ||= rosterings.active_state_or_no_show
    @active_rosterings.select { |r| r.role_id == role.id }
  end

  def passed_cut_off_date?
    (start_datetime - Setting.event_cut_off.days) <= Time.now
  end

  def time_response_required_by
    # Do we have more than enough time to respond?
    if (start_datetime - Setting.event_cut_off.days - Setting.response_time.days) > Time.now
      Setting.response_time.days.from_now

    # Do we have only until the event cut off to respond?
    elsif (start_datetime - Setting.event_cut_off.days) > Time.now
      (start_datetime - Setting.event_cut_off.days)

    # We have no more time to respond! Administrator must do it manually.
    else
      false
    end
  end

  # TODO: Make some nice fancy code to fill up the harder
  # to fill roles first, instead of random
  # e.g of where things with the below code fail:
  #   An event requires 1 usher, 2 coat checks.
  #   Staff A and Staff B have coat check
  #   Staff C has coat check and usher
  #   Staff A and C get assigned as coat checks
  #   Staff B does not have usher so one empty role
  # Ideally, we should assign Staff A and B to coat checks, and Staff C to usher
  # to fill in as many of the roles as possible with the selected staff member
  def select_staff_to_fill_roles(options={})
    # If we haven't set roles yet, or the event has passed its event cut off,
    # then do not set users automatically
    return if roles.blank? || passed_cut_off_date? || cancelled?

    # If the event is working, don't send emails.
    # If the event is approved, then do send emails.
    options = { :send_notification_email => approved? }.merge(options)

    if working? && clear_unconfirmed_rosterings
      Rostering.delete_all(:state => Rostering::States[:unconfirmed], :event_id => self.id)
    end

    @roles = Role.all
    roles.each do |role_id, amount|
      role = @roles.select { |r| r.id == role_id.to_i }.first
      amount_left = (amount.to_i - active_rosterings_for(role).size)
      next if amount_left == 0

      available = role.staff_available_for(self)
      amount_left.times do |i|
        break if available.size == 0
        staff = available.delete_at((rand * (available.size - 1)).round)
        staff.roster_to(self, role_id, false, options)
      end
    end
  end

  def contact_staff_rostered(options = {})
    return false if options[:group].blank? || options[:subject].blank? || options[:body].blank?
    staff = rosterings.with_state(options[:group].split('_or_')).collect { |rostering| rostering.staff }
    Notifier.deliver_email_or_pdf_of(:event_rosterings_contact, staff, self, options[:subject], options[:body])
    true
  end

  def unavailable_staff_rosterings
    # Check how many of the people initially rostered are no longer available for this event
    # Make sure to pass [self] the the available_for? method to ignore this event from the check
    # else it'll report unavailability for everyone because they're already assigned this this one
    rosterings.active_state.select { |rostering| !rostering.staff.available_for?(self, [self]) }
  end

  def unavailable_staff_rosterings?
    !unavailable_staff_rosterings.blank?
  end

  private

  def check_approver_set_if_approving_roster
    if approved?
      if approver_id.blank?
        errors.add_to_base("Cannot approve a roster without an approver set.")
        false
      elsif !Staff.find_by_id(approver_id)
        errors.add_to_base("Approver does not exist.")
        false
      else
        true
      end
    else
      true
    end
  end

  # We need a way to check what attributes changes after it is saved
  # Rails 3 includes a nice feature to do this by default, but for Rails 2.3
  # we need to set the changes in a before_update and access them in an after_update
  def store_changed_attributes
    @changes = changes
  end

  def ensure_staff_available_if_time_changed
    return unless start_datetime_changed? || end_datetime_changed?
    return if ignore_event_conflicts

    unavailable_staff_rosterings.each do |rostering|
      errors.add_to_base("#{rostering.staff.full_name} (#{rostering.role.name}) is not
                          available at the new time of this event.")
    end

    return unavailable_staff_rosterings.blank?
  end

  def cancel_unavailable_staff_if_requested
    # If the admin wants to cancel unvailable staff, lets do so now
    if cancel_unavailable_staff
      unavailable_staff_rosterings.each do |rostering|
        # make sure we don't trigger role positions recalculations for each cancelation
        rostering.skip_staff_selections_callback = false
        # make sure we only send notifications if the event has
        # been approved or they have been confirmed already
        reason = approved? || rostering.confirmed? ? "The start or end times
        of this event have been changed, and according to the system, you are
        either rostered at another event, or not available at that time." : nil
        rostering.cancelled! reason
      end
      self.reload # update the associations so they aren't cached
    end
  end

  def email_staff_if_name_changed
    return unless approved?
    # This event has just had its name changed
    if @changes['name'].is_a?(Array)
      previous_name = @changes['name'].first
      rosterings.active_state.each do |rostering|
        Notifier.deliver_email_or_pdf_of(:event_name_change_notification, rostering.staff, rostering.event, rostering.role, previous_name)
      end
    end
  end

  def email_staff_if_time_changed
    return unless approved?
    # This event has just had its start_datetime and end_datetime changed
    if start_datetime_changed? || end_datetime_changed?
      # For each remaining staff member either unconfirmed or confirmed,
      # send them an email notifying them of the time change
      rosterings.active_state.each do |rostering|
        is_available = !unavailable_staff_rosterings.include?(rostering)
        Notifier.deliver_email_or_pdf_of(:event_time_change_notification, rostering.staff, rostering.event, rostering.role, is_available)
      end
    end
  end

  # Check if the start_datetime has changed. Since we don't deal with seconds,
  # we want to make sure any changes are over a minute. Also, check against
  # the time in UTC, as when the record saves, it'll be converted to UTC
  def start_datetime_changed?
    @changes && @changes['start_datetime'].is_a?(Array) &&
    (@changes['start_datetime'].first.utc - @changes['start_datetime'].second.utc) > 60
  end

  # Check if the end_datetime has changed. Since we don't deal with seconds,
  # we want to make sure any changes are over a minute. Also, check against
  # the time in UTC, as when the record saves, it'll be converted to UTC
  def end_datetime_changed?
    @changes && @changes['end_datetime'].is_a?(Array) &&
    (@changes['end_datetime'].first.utc - @changes['end_datetime'].second.utc) > 60
  end

  def just_approved?
    approved? && @changes && @changes['state'].is_a?(Array) &&
    @changes['state'].last == Event::States[:approved]
  end

  def email_staff_involved_if_approved
    # This event has just been marked as approved roster
    # and event cut off date hasn't passed
    if just_approved? && !passed_cut_off_date?
      rosterings.unconfirmed.each do |rostering|
        if skip_notification_email
          rostering.queue_expiration
        else
          rostering.notify_staff_and_queue_expiration
        end
      end
    end
  end

  def ensure_event_deletable
    return true if cancelled?
    if not_started?
      errors.add_to_base("You cannot delete this event because it has not started. Try canceling it instead.")
      false
    elsif in_progress?
      errors.add_to_base("You cannot delete this event because it is in progress. Please wait until after.")
      false
    elsif finished? && !finished_a_month_ago?
      errors.add_to_base("You cannot delete this event because one month has not passed. Try again later.")
      false
    else
      true
    end
  end

  protected

  def self.sql_between_query
    "(:event_start >= events.start_datetime AND :event_start <= events.end_datetime) OR
    (:event_end >= events.start_datetime AND :event_end <= events.end_datetime) OR
    (events.start_datetime >= :event_start AND events.start_datetime <= :event_end) OR
    (events.end_datetime >= :event_start AND events.end_datetime <= :event_end)".squish
  end

  # TODO: Consider a state machine of some sort?
  def set_state
    self.state = Event::States[:working] if self.state.blank?
  end

  # TODO: Remove this if budget permits adding proper recurring events
  def set_schedule_id
    self.schedule_id = 0
  end

  def set_roles
    self.roles = {}
  end

  # To pass validations:
  #   - event start must be today or in the future, unless overidden
  #   - event end must be after event start
  #   - does not conflict with an event at this venue and time, unless overidden
  def validate
    if start_datetime && end_datetime
      if !allow_past_events && start_datetime <= Time.now
        errors.add(:start_datetime, "must be set to a date in the future.")
        return false
      end
      if end_datetime <= start_datetime
        errors.add(:end_datetime, "must be set to a date after the start time.")
        return false
      end
    end
    if !ignore_event_conflicts && conflicts_with_another_event?
      errors.add_to_base("The event you're adding conflicts with another one at this venue and time. Please change the venue or time below, or save again to ignore the conflicts (not advised).")
      return false
    end
    true
  end
end
