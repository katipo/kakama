class StaffController < ApplicationController
  include Swagger::Blocks

  before_filter :login_required
  before_filter :admin_required, :except => [:dashboard, :show, :edit, :update]
  before_filter :current_staff_can_view_profile, :only => [:dashboard, :show, :edit, :update]

  def dashboard
    @staff = staff_from_id_else_current
  end

  swagger_path '/staffs' do
    operation :get do |operation|
      key :description, 'Fetches all staff records'
      key :notes, "This lists all the active staff"
      key :tags, [
        'staff'
      ]

      ApplicationController.add_common_params(operation)

      parameter name: :search_text,
                in: :query,
                required: false,
                type: :string,
                description: 'Partial search on full name'

      parameter name: :page,
                in: :query,
                required: false,
                type: :integer,
                description: 'Page number'

    end
  end

  def index
    scope = Staff.username_or_full_name_like(params[:search_text], :order_by => :full_name)
    @staffs = scope.paginate :page => params[:page]

    respond_to do |format|
      format.html
      format.json { render json: @staffs }
    end
  end

  swagger_path '/staffs/{id}' do
    operation :get do |operation|
      key :description, 'Fetches a staff record given an id'
      key :notes, ""

      key :tags, [
        'staff'
      ]

      ApplicationController.add_common_params(operation)

      parameter name: :id,
                in: :path,
                required: true,
                type: :string,
                description: 'Staff ID'

      response 200 do
        key :description, 'staff response'
        schema do
          key :type, :array
          items do
            key :'$ref', :Staff
          end
        end
      end
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

  swagger_path '/staffs/' do
    operation :post do |operation|
      key :description, "Creates a staff record given it's attributes"
      ApplicationController.add_common_params(operation)

      key :tags, [
        'staff'
      ]
      parameter do
        key :name, :staff
        key :in, :body
        key :description, 'Staff record to create'
        key :required, true
        schema do
          property :staff do
            key :'$ref', :StaffInput
          end
        end
      end

      response 200 do
        key :description, 'staff response'
        schema do
          key :'$ref', :Staff
        end
      end
    end
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

  swagger_path '/staffs/{id}' do
    operation :put do |operation|
      key :description, "Updates a staff record given it's attributes"
      ApplicationController.add_common_params(operation)

      key :tags, [
        'staff'
      ]

      parameter name: :id,
                in: :path,
                required: true,
                type: :string,
                description: 'Staff ID'

      parameter do
        key :name, :staff
        key :in, :body
        key :description, 'Staff record to update'
        key :required, true
        schema do
          property :staff do
            key :'$ref', :StaffInput
          end
        end
      end

      response 200 do
        key :description, 'staff response'
        schema do
          key :'$ref', :Staff
        end
      end
    end
  end

  def update
    @staff = staff_from_id_else_current
    @staff.skip_current_password = admin? # skips current password check

    if @staff.update_attributes(staff_params)
      respond_to do |format|
        format.html do
          flash[:notice] = 'Staff was successfully updated.'
          redirect_to(@staff)
        end
        format.json do
          render nothing: true, status: :ok
        end
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.json do
          render json: {
            errors: @staff.errors
          }, status: :bad_request
        end
      end
    end
  end

  def destroy
    @staff = staff_from_id_else_current
    if request.delete?
      if @staff.destroy
        respond_to do |format|
          format.html { flash[:notice] = "Staff was successfully destroyed." }
          format.json do
            return render nothing: true, status: :ok
          end
        end

      else
        respond_to do |format|
          format.html { flash[:error] = @staff.errors['base'] }
          format.json do
            return render json: {
              errors: @staff.errors
            }, status: :bad_request
          end
        end
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
