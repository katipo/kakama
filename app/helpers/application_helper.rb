# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_section_if(controller)
    (params[:controller].to_sym == controller &&
      params[:action] != 'dashboard') ? 'current_section' : ''
  end
end
