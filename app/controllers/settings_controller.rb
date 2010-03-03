class SettingsController < ApplicationController
  before_filter :admin_required

  def index
    Setting.update(params[:settings]) if request.post? && !params[:settings].blank?
  end
end
