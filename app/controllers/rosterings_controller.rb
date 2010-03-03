class RosteringsController < ApplicationController
  before_filter :login_required
  before_filter :admin_required, :except => [:accept, :decline]
  before_filter :fetch_rostering_event_staff_and_role, :except => [:search, :add]

  #
  # Staff Member accessable functions
  #

  def accept
    if request.put?
      @rostering.confirmed!
      flash[:notice] = "You have confirmed your role as a #{@role.name} at this event. You will be sent an email soon confirming the details."
      redirect_to @event
    end
  end

  def decline
    if request.put?
      @rostering.declined!
      flash[:notice] = "You have declined your role as a #{@role.name} at this event."
      redirect_to @event
    end
  end

  #
  # Administrator accessable functions
  #

  # Search for a staff member to add a rostering for
  def search
    @event = Event.find(params[:event_id])
    scope = Staff.username_or_full_name_like(params[:search_text])
    scope = scope.available_for(@event) unless params[:show_all_staff]
    @staffs = scope.paginate :page => params[:page]
  end

  # Add a staff member to an event as a specific role
  def add
    staff = Staff.find(params[:staff_id])
    event = Event.find(params[:event_id])
    role = Role.find(params[:role_id])
    if request.post?
      if staff.roster_to(event, role, params[:ignore_unavailability], :send_notification_email => event.approved?)
        flash[:notice] = "#{staff.full_name} has been added as a #{role.name} to this event."
        redirect_to event
      else
        flash[:error] = "#{staff.full_name} could not be rostered as a #{role.name} to this event."
      end
    end
  end

  # Approve a staff member for an event as a specific role
  def approve
    if request.put?
      @rostering.confirmed!
      flash[:notice] = "#{@staff.full_name} has been approved as a #{@role.name} at this event."
      redirect_to @event
    end
  end

  # Reject a staff member for a specific role at an event
  def reject
    if request.put?
      @rostering.rejected!
      flash[:notice] = "#{@staff.full_name} has been rejected as a #{@role.name} at this event."
      redirect_to @event
    end
  end

  # Deroster a staff member from the event before an event roster has been finalised
  def deroster
    if request.delete?
      @rostering.destroy
      flash[:notice] = "#{@staff.full_name} was derostered from this event."
      redirect_to @event
    end
  end

  # Cancel a staff member from the event after an event roster has been finalised
  def cancel
    if request.put?
      reason = !params[:cancel_reason_custom].blank? ? params[:cancel_reason_custom] : params[:cancel_reason_preset]
      @rostering.cancelled! reason
      flash[:notice] = "#{@staff.full_name} has been cancelled as a #{@role.name} at this event."
      redirect_to @event
    end
  end

  # Mark a staff member as a no show for the event after the event has finished
  def mark_no_show
    if request.put?
      @rostering.no_show!
      flash[:notice] = "#{@staff.full_name} has been marked as a no show at this event."
      redirect_to @event
    end
  end

  # Reverse a no show marking
  def undo_no_show
    if request.put?
      @rostering.confirmed!(false)
      flash[:notice] = "#{@staff.full_name} has been removed from the no show lists for this event."
      redirect_to @event
    end
  end

  private

  def fetch_rostering_event_staff_and_role
    @rostering = Rostering.find_by_id(params[:id])
    if @rostering
      @event = @rostering.event
      @staff = @rostering.staff
      @role = @rostering.role
    else
      flash[:error] = "Was unable to locate the rostering you tried to access."
      redirect_to root_url
    end
  end
end