class VenuesController < ApplicationController

  before_filter :login_required
  before_filter :admin_required, :except => [:show]

  active_scaffold :venue do |config|
    config.columns = [:name, :description]
    columns[:name].required = true
  end

  # This must be included after active_scaffold config because it overrides
  # some of the methods added by the controller
  include DisplayDeleteErrors
end
