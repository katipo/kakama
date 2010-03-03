module StaffHelper
  # Takes an events result and collects an array of arrays,
  # containing the event and the rostering for the current user
  def collect_event_and_rosterings_for(events, staff)
    events = events.uniq # incase we have identical events

    events.collect do |event|
      rosterings = staff.active_rosterings_at(event)
      rosterings.size > 0 ? [event, rosterings] : nil
    end.compact
  end
end
