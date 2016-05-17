# TODO: Complete implementation if budget permits
# Currently not implemented
class SchedulesController < ApplicationController
  before_filter :login_required
  before_filter :admin_required

  active_scaffold :schedule do |config|
    config.columns = [:name, :interval, :delay_mapping_id]
    list.columns = [:name]

    columns[:name].required = true
    columns[:delay_mapping_id].required = true
    columns[:interval].required = true

    columns[:delay_mapping_id].label = "Delay Type"
    columns[:delay_mapping_id].form_ui = :select
    columns[:delay_mapping_id].options = [['', '']] + Schedule::Types
    columns[:delay_mapping_id].description = "(the next event time is calculated by mutliplying the interval by the delay type, e.g. 5 days)"
  end
end
