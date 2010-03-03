ActionController::Routing::Routes.draw do |map|
  map.login "login", :controller => 'staff_sessions', :action => 'new'
  map.logout "logout", :controller => 'staff_sessions', :action => 'destroy'
  map.dashboard "dashboard", :controller => 'staff', :action => 'dashboard'

  [:detail_types, :venues, :roles, :schedules, :email_logs].each do |as_resource|
    map.resources as_resource, :active_scaffold => true
  end

  [:password_resets, :staff_sessions].each do |resource|
    map.resources resource
  end

  map.resources :events,
  :member => {
    :destroy => [:get, :delete],
    :cancel => [:get, :delete],
    :contact_staff => [:get, :post]
  },
  :collection => {
    :mass_approve => [:post]
  }

  map.resources :rosterings, :only => :none,
  :member => {
    :accept => [:get, :put],
    :decline => [:get, :put],
    :approve => [:get, :put],
    :reject => [:get, :put],
    :deroster => [:get, :delete],
    :cancel => [:get, :put],
    :mark_no_show => [:get, :put],
    :undo_no_show => [:get, :put]
  },
  :collection => {
    :search => [:get, :post],
    :add => [:get, :post]
  }

  map.resources(:staffs, :as => "staff", :controller => "staff",
  :member => {
    :destroy => [:get, :delete],
    :dashboard => :get,
    :contact => [:get, :post]
  },
  :collection => {
    :contact_all => [:get, :post]
  }) do |staff|
    staff.resources :availabilities, :as => "availability", :controller => "availability",
    :member => {
      :destroy => [:get, :delete],
      :split => [:get, :post]
    }
  end

  map.resources :reports, :only => :index,
  :member => {
    :work_history => :get
  },
  :collection => {
    :staff_list => :get,
    :work_history => :get,
    :events => :get
  }

  map.resources :settings, :only => :index,
  :collection => {
    :index => [:get, :post]
  }

  map.root :controller => "staff_sessions", :action => "new"
end
