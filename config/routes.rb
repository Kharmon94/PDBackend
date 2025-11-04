Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/login', to: 'auth#login'
      post 'auth/signup', to: 'auth#signup'
      get 'auth/me', to: 'auth#me'
      post 'auth/logout', to: 'auth#logout'
      
      # Business routes
      resources :businesses, only: [:index, :show, :create, :update, :destroy] do
        member do
          post 'track_click'
        end
      end
      
      get 'businesses/my', to: 'businesses#my_businesses'
      get 'businesses/:id/analytics', to: 'businesses#analytics'
      
      # Saved deals routes
      resources :saved_deals, only: [:index, :create, :destroy]
      post 'saved_deals/toggle', to: 'saved_deals#toggle'
      
      # User profile routes
      get 'users/profile', to: 'users#profile'
      patch 'users/profile', to: 'users#update_profile'
      patch 'users/password', to: 'users#update_password'
      delete 'users/account', to: 'users#destroy_account'
      
      # Distribution partner routes
      namespace :distribution do
        get 'dashboard', to: 'distribution#dashboard'
        get 'businesses', to: 'distribution#businesses'
        get 'white_label', to: 'distribution#get_white_label'
        patch 'white_label', to: 'distribution#update_white_label'
        get 'stats', to: 'distribution#stats'
      end
      
      # Admin routes
      namespace :admin do
        get 'stats', to: 'admin#stats'
        get 'users', to: 'admin#users'
        get 'businesses', to: 'admin#businesses'
        get 'pending_approvals', to: 'admin#pending_approvals'
        patch 'businesses/:id/feature', to: 'admin#toggle_featured'
        patch 'businesses/:id/approve', to: 'admin#approve_business'
        patch 'businesses/:id/reject', to: 'admin#reject_business'
        patch 'users/:id/suspend', to: 'admin#suspend_user'
        patch 'users/:id/activate', to: 'admin#activate_user'
        delete 'users/:id', to: 'admin#destroy_user'
        delete 'businesses/:id', to: 'admin#destroy_business'
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
