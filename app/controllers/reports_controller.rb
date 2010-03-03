class ReportsController < ApplicationController
  before_filter :admin_required

  def index
  end

  def staff_list
    @staff = Staff.ascend_by_full_name.all(:include => :staff_details)
    @detail_types = DetailType.all
    respond_to do |format|
      format.html
      format.xls { render :layout => false }
      format.csv { render :layout => false }
      format.xml do
        headers['Content-Disposition'] = 'attachment; filename="staff_list.xml"'
        render :layout => false
      end
    end
  end

  def work_history
    if params[:id]
      @staff = Staff.find(params[:id])
    else
      scope = Staff.username_or_full_name_like(params[:search_text])
      @staffs = scope.paginate :page => params[:page]
    end
  end

  def events
    if params[:start_date].blank?
      @date = Time.now
    else
      @date = Time.parse(params[:start_date])
      @events = Event.occuring_at(@date.beginning_of_day, @date.end_of_day).all(:include => :rosterings)
      @rosterings = @events.collect { |e| e.rosterings.active_state }.flatten.compact
    end
  end
end
