class VenuesController < ApplicationController
  before_filter :login_required
  before_filter :admin_required, :except => [:show]

  active_scaffold :venue do |config|
    config.columns = [:name, :description]
    columns[:name].required = true
  end
end
