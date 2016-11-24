module Authentication
  unless included_modules.include? Authentication

    def self.included(klass)
      klass.send :helper_method, :current_staff, :admin?
    end

    private

    def current_staff_session
      @current_staff_session ||= staff_session_from_api_key || StaffSession.find
    end

    def staff_session_from_api_key
      if api_key = params[:api_key]
        user = Staff.find_by_single_access_token(api_key)
        return StaffSession.create(user) unless user.blank?
      end
    end

    def current_staff
      @current_staff ||= current_staff_session.record if current_staff_session
    end

    def admin?
      current_staff && current_staff.staff_type == 'admin'
    end

    def logout_required
      if current_staff
        flash[:error] = "The page you requested requires you be logged out."
        redirect_to dashboard_path
      end
    end

    def login_required
      unless current_staff
        respond_to do |format|
          format.html do
            flash[:error] = "The page you requested requires you be logged in."
            redirect_to login_path
          end

          format.json { render :nothing => true, :status => :unauthorized }
        end
      end
    end

    def admin_required
      unless admin?
        respond_to do |format|
          format.html do
            flash[:error] = "The page you requested requires you be an admin."
            redirect_to dashboard_path
          end

          format.json { render :nothing => true, :status => :unauthorized }
        end
      end
    end

  end
end