# A PDF generation class that acts like action mailer in that you can call
# generate_staff_member_rostered but drop generate_ on the method definition
class PdfGenerator < PdfGeneration

  #
  # All pdf generation methods are sorted alphabetically
  #

  def email_to_all_staff(staff, subject, body)
    address_for(staff)
    text "An administrator has sent all staff members the following notice."
    move_down 10
    inside_horizontal_rules do
      text "Subject:", :style => :bold
      text subject
      move_down 10
      text "Message:", :style => :bold
      text body
    end
  end

  def event_cancelled_notification(staff, event, role)
    address_for(staff)
    text "The event #{event.name} at #{event.venue.name} has been cancelled."
    move_down 10
    text "Your participation there as a #{role.name} is no longer required."
  end

  def event_name_change_notificiation(staff, event, role, previous_name)
    address_for(staff)
    text "The event named '#{previous_name}' has been renamed as '#{event.name}'."
    move_down 10
    text "This does not affect the events operation."
    move_down 10
    text "Your attendance as a #{role.name} is still required."
  end

  def event_rosterings_contact(staff, event, subject, body)
    address_for(staff)
    text "An administrator has contacted you regarding the event #{event.name}."
    inside_horizontal_rules do
      text "Subject:", :style => :bold
      text subject
      move_down 10
      text "Message:", :style => :bold
      text body
    end
  end

  def event_time_change_notification(staff, event, role, is_available)
    address_for(staff)
    text "The time of the event '#{event.name}' that you are rostered as a #{role.name} for has had it's start or end dates changed."
    move_down 10
    text "The new details are as follows:"
    move_down 10
    event_details_for(event)
    move_down 10
    if is_available
      text "The system shows that you are available to work at this new time, which is why you have been contacted about this change."
    else
      text "The system shows that you are not available to work at this new time. Please contact the administrator to sort out why you are unable to attend, and cancel your rostering if needed."
    end
  end

  def multiple_rostering_created_notification(staff, events_and_roles)
    address_for(staff)
    text "You have been scheduled to work at multiple new events."
    move_down 10
    events_and_roles.each do |event, role|
      event_details_for(event, role)
      move_down 10
    end
    text "* you have till such time to either accept or decline this event, before the system automatically marks your rostering as declined."
    move_down 10
    text "You will need to contact the administrator to confirm or decline your availability for any of these events."
    move_down 10
    text "If you do not respond within the required time for an event, you will automatically be moved to the declined list for that event."
  end

  def rostering_cancelled_notification(staff, event, role, reason='')
    address_for(staff)
    text "Your involvement as a #{role.name} at the event '#{event.name}' has been cancelled by an administrator."
    move_down 10
    text "Therefore, you are no longer needing to attend the event."
    unless reason.blank?
      move_down 10
      text "Reason for cancelation:", :style => :bold
      text "#{reason}"
    end
  end

  def rostering_confirmed_notification(staff, event, role)
    address_for(staff)
    text "This document is confirming the details of an event you have been rostered to."
    move_down 10
    text "You will be working at the following event as a #{role.name}."
    move_down 10
    event_details_for(event)
  end

  def rostering_created_notification(staff, event, role)
    address_for(staff)
    text "You have been scheduled to work at a new event as an #{role.name}."
    move_down 10
    event_details_for(event)
    move_down 10
    text "* you have till such time to either accept or decline this event, before the system automatically marks your rostering as declined."
    move_down 10
    text "You will need to contact the administrator to confirm or decline your availability for this event."
    move_down 10
    text "If you do not respond within the required time, you will automatically be moved to the declined list."
  end

  def staff_account_creation(staff)
    address_for(staff)
    text "An account has been setup for you at #{Setting.site_url}."
    move_down 10
    text "You can login with the following credentials:"
    move_down 10
    text "Username: #{staff.username}"
    text "Password: #{staff.password}"
    move_down 10
    text "This is the only time your password will be sent to you in plain text. Save it locally."
    move_down 10
    text "If you forget your password, you will have to have it reset."
  end

  private

  def address_for(staff)
    text staff.full_name
    # if this member has a postal or physical address setup, then
    # add it to the top of the pdf, else leave space for the
    # administrator to fill it in manually after they print it
    if !staff.sending_address.blank?
      text staff.sending_address
    else
      move_down 40
    end
    move_down 15
    text Time.now.to_date.to_s(:nz)
    move_down 15
    text "#{staff.full_name},"
    move_down 10
  end

  def signoff
    move_down 40
    text "Regards"
    text Setting.site_name
    text Setting.site_url
  end

  def header
    lazy_bounding_box bounds.top_left, :height => margin_box.height, :width => margin_box.width do
      text Setting.site_name, :size => 20, :style => :bold, :align => :right
      text Setting.site_url, :size => 15, :align => :right
    end.draw
  end

  def footer
    signoff
    lazy_bounding_box bounds.bottom_left, :height => margin_box.height, :width => margin_box.width do
      stroke { horizontal_rule }
      move_down 10
      text "#{Setting.site_name} - #{Setting.site_url}", :size => 10, :align => :center
    end.draw
  end

  def inside_horizontal_rules(&block)
    move_down 10; stroke { horizontal_rule }; move_down 10
    yield
    move_down 10; stroke { horizontal_rule }; move_down 10
  end

  def event_details_for(event, role=nil)
    data = Array.new
    data << ["Name:", event.name]
    data << ["Venue:", event.venue.name]
    data << ["Description:", event.description] unless event.description.blank?
    data << ["Event Reporting Time:", event.start_datetime.to_s(:long_with_day)]
    data << ["Event end:", event.end_datetime.to_s(:long_with_day)]
    data << ["Role:", role.name] if role
    data << ["Response Deadline:", event.time_response_required_by.to_s(:long_with_day)] if event.time_response_required_by

    table data, :row_colors => ["ffffff", 'dddddd']
  end

end
