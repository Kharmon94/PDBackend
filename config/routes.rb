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
      
      # Admin routes
      namespace :admin do
        get 'stats', to: 'admin#stats'
        get 'users', to: 'admin#users'
        get 'businesses', to: 'admin#businesses'
        patch 'businesses/:id/feature', to: 'admin#toggle_featured'
        delete 'users/:id', to: 'admin#destroy_user'
        delete 'businesses/:id', to: 'admin#destroy_business'
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
