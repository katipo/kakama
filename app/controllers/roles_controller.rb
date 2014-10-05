class RolesController < ApplicationController
  before_filter :login_required
  before_filter :admin_required

  active_scaffold :role do |config|
    config.columns = [:name, :description]
    columns[:name].required = true
  end
end
