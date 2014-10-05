# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :store_last_location

  include Authentication

  private

  # Store the last visited location unless:
  #  * it's one of the staff sessions actions (login, logout)
  #  * it's a post action (create, update, destroy)
  #  * it's a request other than html (csv, xls, xml)
  def store_last_location
    return if params[:controller] == 'staff_sessions' || !request.get? || request.format != 'text/html'
    session[:return_to] = request.request_uri
  end

  # Get the current staff member based on the url.
  # If staff_id is set an an integer, find the staff member using that
  # if staff_id is not set, but id is, find the staff member using that
  # finally, if neither id is set or they aren't integers (can be 'current'),
  # then just use the current user
  def staff_from_id_else_current
    if params[:staff_id] && params[:staff_id].to_i > 0
      Staff.find(params[:staff_id])
    elsif !params[:staff_id] && params[:id] && params[:id].to_i > 0
      Staff.find(params[:id])
    else
      current_staff
    end
  end
end
