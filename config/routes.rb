Kakama::Application.routes.draw do
  match 'login' => 'staff_sessions#new', :as => :login
  match 'logout' => 'staff_sessions#destroy', :as => :logout
  match 'dashboard' => 'staff#dashboard', :as => :dashboard
  resources :detail_types
  resources :venues
  resources :roles
  resources :schedules
  resources :email_logs
  resources :password_resets
  resources :staff_sessions
  resources :events do
    collection do
      post :mass_approve
    end
    member do
      get :cancel
      delete :cancel
      get :contact_staff
      post :contact_staff
      get :destroy
      delete :destroy
    end

  end

  resources :rosterings, :only => :none do
    collection do
      get :search
      post :search
      get :add
      post :add
    end
    member do
      get :accept
      put :accept
      get :undo_no_show
      put :undo_no_show
      get :cancel
      put :cancel
      get :reject
      put :reject
      get :decline
      put :decline
      get :approve
      put :approve
      get :deroster
      delete :deroster
      get :mark_no_show
      put :mark_no_show
    end

  end

  resources :staffs do
    collection do
      get :contact_all
      post :contact_all
    end
    member do
      get :dashboard
      get :contact
      post :contact
      get :destroy
      delete :destroy
    end
    resources :availabilities do

      member do
        get :split
        post :split
        get :destroy
        delete :destroy
      end

    end
  end

  resources :reports, :only => :index do
    collection do
      get :events
      get :dashboard
      get :contact
      post :contact
      get :destroy
      delete :destroy
    end
    resources :availabilities do

      member do
        get :split
        post :split
        get :destroy
        delete :destroy
      end

    end
  end

  resources :reports, :only => :index do
    collection do
      get :events
      get :work_history
      get :staff_list
    end
    member do
      get :work_history
    end

  end

  resources :settings, :only => :index do
    collection do
      get :index
      post :index
    end


  end

  root :to => 'staff_sessions#new'
end
