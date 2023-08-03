Rails.application.routes.draw do
  post "/hello", to: "pages#hello"
  root 'pages#home'
  devise_for :users, :controllers => {
    sessions: 'users/sessions', registrations: 'users/registrations'
  }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :admin do
    resources :qualifications, only: [:index, :new, :create]
    resources :interests do
      collection do
        post :import_csv
      end
    end
  end

  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

    devise_scope :user do
      get '/users/sign_out' => 'devise/sessions#destroy'
      get '/users/sign_in'  => 'devise/sessions#new'
    end
    post 'accounts/otp_verification', to: 'accounts#otp_verification'
  
    resources :qualifications, only: [:create, :new, :index]
    resources :academics, only: [:index, :create, :update, :destroy]
    resources :interests
    resources :users, only: [:show]
    resources :assessments do
      member do
        get 'show_questions'
        post 'submit_answer', to: 'assessments#submit_answer', as: 'submit_answer'
      end
    end
    resources :assessment_questions, only: [:index, :create, :update, :show, :destroy]
    resources :options, only: [:create, :update, :index]
    post '/payments', to: 'payments#create'
end
