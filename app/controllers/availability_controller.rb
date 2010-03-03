class AvailabilityController < ApplicationController
  before_filter :login_required
  before_filter :parse_start_date_from_params_or_now
  before_filter :prepare_current_staff_member
  before_filter :ensure_availability_changeable, :only => %w{ edit update destroy }

  # The following instance varisables are set in before filters, and which actions will set them
  #   @time         - all actions
  #   @staff        - all actions
  #   @availability - edit, update, destroy

  helper_method :changing_own_availability?

  def index
    @availabilities = @staff.availabilities_overlapping(@time, @time + 6.days)
    @times = @availabilities.collect { |a| a.times(@time) }.flatten
  end

  def show
    redirect_to staff_availabilities_path(@staff)
  end

  def new
    @availability = Availability.new(:staff_id => @staff)
  end

  def create
    @availability = Availability.new(params[:availability])
    @availability.staff = @staff
    @availability.edited_by_administrator = admin?
    @availability.changing_own_availability = changing_own_availability?

    if @availability.save
      flash[:notice] = 'Availability was successfully created.'
      redirect_to(staff_availabilities_path(@availability.staff, :start_date => @availability.start_date))
    else
      render :action => "new"
    end
  end

  def edit
    redirect_to new_staff_availability_path(@staff) unless @availability
  end

  def update
    @availability.edited_by_administrator = admin?
    @availability.changing_own_availability = changing_own_availability?
    if @availability.update_attributes(params[:availability])
      flash[:notice] = 'Availability was successfully updated.'
      redirect_to(staff_availabilities_path(@availability.staff, :start_date => @availability.start_date))
    else
      render :action => "edit"
    end
  end

  def destroy
    if request.delete?
      if @availability.destroy
        flash[:notice] = 'Availability was successfully removed.'
      else
        flash[:error] = @availability.errors['base']
      end
      redirect_to(staff_availabilities_path(@staff))
    end
  end

  def split
    @availability = availability_from_id_else_current
    if request.post?
      if @availability.split_at(params[:availability])
        flash[:notice] = 'Your availability has been split on the date specified.'
        redirect_to(staff_availabilities_path(@staff))
      else
        flash[:error] = @availability.errors['base']
        redirect_to(split_staff_availability_path(@staff, @availability))
      end
    end
  end

  private

  def parse_start_date_from_params_or_now
    @time = (Chronic.parse(params[:start_date]) || Time.now).beginning_of_week
  end

  def prepare_current_staff_member
    @staff = staff_from_id_else_current
  end

  def ensure_availability_changeable
    @availability = availability_from_id_else_current
    if @availability
      if @availability.admin_locked? && !admin?
        flash[:error] = 'This Availability has been locked by an administrator. You cannot edit it until they unlock it.'
        redirect_to staff_availabilities_path(@staff)
      end
      if @availability.events_rostered_at_this_time?
        if admin?
          flash[:error] = "Caution: This staff member has events rostered during this availability. Editing it could conflict with these events."
        else
          flash[:error] = "You can't edit or delete this availability because you are rostered to an event at this time. Perhaps split it first."
          redirect_to staff_availabilities_path(@staff)
        end
      end
    end
  end

  # Get the current availability based on the url.
  # If id is set, find the availability using that otherwise get
  # the first availability that fits the requested time slot
  def availability_from_id_else_current
    if params[:id] && params[:id].to_i > 0
      Availability.find(params[:id])
    else
      @staff.availabilities_overlapping(@time, @time + 6.days).first
    end
  end

  def changing_own_availability?
    current_staff == staff_from_id_else_current
  end
end
