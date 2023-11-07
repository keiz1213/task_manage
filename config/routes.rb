Rails.application.routes.draw do
  root to: 'tasks#index'
  namespace :admin do
    resources :users
  end
  resources :tasks, except: :show do
    member do
      patch :update_state
    end
  end
  namespace :guest do
    post '/login', to: 'sessions#create'
  end
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '*not_found' => 'application#routing_error'
  post '*not_found' => 'application#routing_error'
end
