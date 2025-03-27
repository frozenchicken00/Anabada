Rails.application.routes.draw do
  root "home#index"

  # User routes
  resources :users, only: [ :show, :edit, :update, :destroy ] do
    member do
      patch "update_password"  # Optional: separate route for password updates
    end
  end

  resources :sessions, except: [ :index, :edit, :show, :update, :new ]

  resources :categories, except: [ :show ]

  resources :products do
    resources :categories, only: [ :index ] do
      resources :products, only: [ :index ]
    end
    resources :comments do
      member do
        post "helpful_vote"
        get "helpful_vote"
      end
    end
  end

  # Messaging routes
  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ] do
      collection do
        post :create_ajax
        post :mark_as_read
      end
    end
  end

  get "sign_up", to: "users#new", as: "sign_up"
  get "admin/sign_up", to: "users#new_admin", as: "admin_sign_up"
  post "users", to: "users#create"

  get "sign_in", to: "sessions#new", as: "sign_in"
  post "sessions", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy", as: "sign_out"
  get "/auth/:provider/callback", to: "authentications#create"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Mount ActionCable server
  mount ActionCable.server => "/cable"
end
