class PasswordResetsController < ApplicationController
  before_filter :logout_required
  before_filter :load_staff_using_perishable_token, :only => [:edit, :update]

  def index
    redirect_to edit_password_reset_url(params[:reset_token]) unless params[:reset_token].blank?
  end

  def new
  end

  def create
    @staff = Staff.find_by_email(params[:email])
    if @staff
      @staff.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. Please check your email."
      redirect_to root_url
    else
      flash[:error] = "No user was found with that email address. Contact an admin to have them reset your password."
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    @staff.password = params[:staff][:password]
    @staff.password_confirmation = params[:staff][:password_confirmation]
    @staff.skip_current_password = true
    if @staff.save
      flash[:notice] = "Password successfully updated. You have now been logged in."
      redirect_to login_url
    else
      render :action => 'edit'
    end
  end

  private

  def load_staff_using_perishable_token
    @staff = Staff.find_using_perishable_token(params[:id])
    unless @staff
      flash[:error] = "Invalid password reset request. Try copying the url from the email into the browser, or restart the password reset process. If problems persist, contact an admin."
      redirect_to root_url
    end
  end
end
