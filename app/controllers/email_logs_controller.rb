class EmailLogsController < ApplicationController
  before_filter :login_required
  before_filter :admin_required

  active_scaffold :email_log do |config|
    config.columns = [:email_type, :subject, :staff, :event, :created_at]
    list.columns = [:email_type, :staff, :event, :created_at]
    config.list.sorting = { :created_at => :desc }
  end
end
