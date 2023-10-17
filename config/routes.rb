Rails.application.routes.draw do
  root to: 'tasks#index'
  resources :tasks do
    member do
      patch :update_state
    end
  end
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
end
