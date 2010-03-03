module Authentication
  unless included_modules.include? Authentication

    def self.included(klass)
      klass.send :helper_method, :current_staff, :admin?
    end

    private

    def current_staff_session
      @current_staff_session ||= StaffSession.find
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
        flash[:error] = "The page you requested requires you be logged in."
        redirect_to login_path
      end
    end

    def admin_required
      unless admin?
        flash[:error] = "The page you requested requires you be an admin."
        redirect_to dashboard_path
      end
    end

  end
end