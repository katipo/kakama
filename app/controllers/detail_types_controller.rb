class DetailTypesController < ApplicationController
  before_filter :login_required
  before_filter :admin_required

  active_scaffold :detail_type do |config|
    config.columns = [:name, :field_type]

    list.columns.exclude :field_type

    columns[:name].required = true

    columns[:field_type].required = true
    columns[:field_type].form_ui = :select
    columns[:field_type].options = DetailType::Types
  end
end
