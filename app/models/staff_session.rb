class StaffSession < Authlogic::Session::Base
  logout_on_timeout (Setting.session_timeout > 0)
end
