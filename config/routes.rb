Rails.application.routes.draw do
  resources :admins do
    collection do
      get :bulk_manage
      post :bulk_manage
      delete :bulk_delete
    end
  end

  resources :contacts do
    collection do
      post :bulk_actions
    end
  end

  resources :password_resets, only: [:new, :create, :edit, :update], param: :token
  resources :sessions, only: [:new, :create, :destroy]
  resources :users

  get "settings/password", to: "users#change_password", as: :edit_password
  patch "settings/password", to: "users#update_password", as: :update_password

  post "password/forgot", to: "password_resets#create"
  post "password/reset", to: "password_resets#update"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
  root "sessions#new"
end