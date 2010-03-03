module EventsHelper
  def display_notices_and_errors
    html = String.new
    %w{ event_in_progress event_finished event_cancelled event_deleted }.each do |notice|
      html += display_notice_for(notice)
    end
    %w{ unapproved_event unfilled_roles overfilled_roles
        passed_cut_off roster_never_approved conflicting_events }.each do |error|
      html += display_error_for(error) if admin?
    end
    html
  end

  def display_notice_for(type)
    msg = case type.to_sym
    when :event_in_progress
      return '' if @event.cancelled? || !@event.in_progress?
      "This event is currently in progress."
    when :event_finished
      return '' if @event.cancelled? || !@event.finished?
      "This event finished #{time_ago_in_words(@event.end_datetime)} ago."
    when :event_cancelled
      return '' if @event.deleted? || !@event.cancelled?
      "This event has been cancelled."
    when :event_deleted
      return '' if !@event.deleted?
      "This event has been deleted. It exists for statistics only. How did you get here?"
    else
      raise "ERROR: Did not recognise notice type: #{type}"
    end
    content_tag("div", msg, :class => 'flash_notice')
  end

  def display_error_for(type)
    msg = case type.to_sym
    when :unapproved_event
      return '' if @event.cancelled? || @event.approved? || @event.finished?
      "This event has not been finalised, therefore staff have not been notified of it yet."
    when :unfilled_roles
      return '' if @event.cancelled? || @event.started? || @event.filled_all_roles?
      "Not all roles are filled. See below for more details."
    when :overfilled_roles
      return '' if @event.cancelled? || @event.started? || !@event.overfilled_any_roles?
      "Some roles have been overfilled. See below for more details."
    when :passed_cut_off
      return '' if @event.cancelled? || @event.started? || !@event.passed_cut_off_date?
      str = "The event has passed the cut off date (#{Setting.event_cut_off} days before event). "
      str << "You must assign staff manually to the remaining unfilled positions. Any staff added to the roster from this point on will need to be contacted manually." if !@event.filled_all_roles?
      str
    when :roster_never_approved
      return '' if @event.cancelled? || !(@event.finished? && @event.working?)
      "The event has finished but it's roster was never approved, so no one was notified about it."
    when :conflicting_events
      return '' if @event.cancelled? || @event.other_events_at_this_place_and_time.size == 0
      str = "This event conflicts with the following events at this place and time: "
      str << @event.other_events_at_this_place_and_time.collect { |e| link_to(e.name, event_path(e)) }.join(', ')
      str
    else
      raise "ERROR: Did not recognise error type: #{type}"
    end
    content_tag("div", msg, :class => 'flash_error')
  end

  def confirmation_message_for(type)
    "Are you sure? If you change your mind, you will need to contact " +
    "the administrator to remove your from the #{type} lists."
  end
end
