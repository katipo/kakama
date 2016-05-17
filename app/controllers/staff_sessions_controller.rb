class StaffSessionsController < ApplicationController
  def index
    redirect_to login_path
  end

  def new
    if current_staff
      flash.keep
      redirect_to dashboard_path
    end
    @staff_session = StaffSession.new
  end

  def create
    @staff_session = StaffSession.new(params[:staff_session])
    if @staff_session.save
      flash[:notice] = "Successfully logged in."
      redirect_to (session[:return_to] ? session[:return_to] : dashboard_url)
    else
      render :action => 'new'
    end
  end

  def destroy
    @staff_session = StaffSession.find
    if @staff_session
      @staff_session.destroy
      session[:return_to] = nil
    end
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end
end
