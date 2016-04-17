class VenuesController < ApplicationController
  before_filter :login_required
  before_filter :admin_required, :except => [:show]

  active_scaffold :venue do |config|
    config.columns = [:name, :description]
    columns[:name].required = true
  end

  def do_destroy
    destroy_find_record
    self.successful = @record.destroy

    if @record.errors.count > 0
      flash[:warning] = (@record.errors.messages[:base] || []).join(' ')
      self.successful = false
    end
  end
end
