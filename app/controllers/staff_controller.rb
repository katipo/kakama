class StaffController < ApplicationController
  before_filter :login_required
  before_filter :admin_required, :except => [:dashboard, :show, :edit, :update]
  before_filter :current_staff_can_view_profile, :only => [:dashboard, :show, :edit, :update]

  def dashboard
    @staff = staff_from_id_else_current
  end

  def index
    scope = Staff.username_or_full_name_like(params[:search_text], :order_by => :full_name)
    @staffs = scope.paginate :page => params[:page]

    respond_to do |format|
      format.html
      format.json { render json: @staffs }
    end
  end

  def show
    @staff = staff_from_id_else_current

    respond_to do |format|
      format.html
      format.json { render json: @staff}
    end
  end

  def new
    @staff = Staff.new
    @staff.start_date = Time.new.strftime('%Y-%m-%d')
  end

  def edit
    @staff = staff_from_id_else_current
  end

  def create
    @staff = Staff.new(staff_params)

    if @staff.save
      flash[:notice] = 'Staff was successfully created. '
      if !@staff.email.blank?
        flash[:notice] += 'The user has been emailed notifying them of their account has been created.'
      else
        flash[:notice] += 'This user must be notified manually that their account has been created.'
      end
      redirect_to(@staff)
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.json do
          render json: {
            errors: @staff.errors
          }, status: :bad_request
        end
      end
    end
  end

  def update
    @staff = staff_from_id_else_current
    @staff.skip_current_password = admin? # skips current password check

    if @staff.update_attributes(staff_params)
      flash[:notice] = 'Staff was successfully updated.'
      redirect_to(@staff)
    else
      render :action => "edit"
    end
  end

  def destroy
    @staff = staff_from_id_else_current
    if request.delete?
      if @staff.destroy
        flash[:notice] = "Staff was successfully destroyed."
      else
        flash[:error] = @staff.errors['base']
      end
      redirect_to(staffs_path)
    end
  end

  def contact
    @staff = staff_from_id_else_current

    if @staff.email.blank?
      flash[:error] = "You cannot send #{@staff.full_name} an email because they have no email set."
      redirect_to(@staff)
    end

    if request.post?
      if @staff.contact(params)
        flash[:notice] = "#{@staff.full_name} was sent the email you submitted."
        redirect_to(@staff)
      else
        flash[:error] = "Please enter an subject and email body."
      end
    end
  end

  def contact_all
    if request.post?
      if Staff.contact_all(params)
        flash[:notice] = "Email was sent to all staff members."
        redirect_to(staffs_path)
      else
        flash[:error] = "Please enter an subject and email body."
      end
    end
  end

  private

  def staff_password_params
    [:password, :password_confirmation, :current_password]
  end

  def staff_params
    params.require(:staff)
      .permit(*(Staff.strong_attributes + staff_password_params))
  end

  def current_staff_can_view_profile
    unless admin? || staff_from_id_else_current == current_staff
      flash[:error] = "Only administrators or the staff member themselves can view their profile or edit it."
      redirect_to root_url
    end
  end
end
