Rails.application.routes.draw do
  root to: 'tasks#index'
  resources :tasks do
    member do
      patch :update_state
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
