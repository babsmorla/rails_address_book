Rails.application.routes.draw do
  resources "sessions", only: [:new, :create, :destroy ]
  resources "users"
  resources "contacts" 

  get 'settings/password', to: 'users#change_password', as: :edit_password
patch 'settings/password', to: 'users#update_password', as: :update_password

  # resources :users do
  #   member do
  #     get 'change_password' # This creates the view page
  #     patch 'update_password' # This handles the form submission
  #   end
  # end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "sessions#new"
end
