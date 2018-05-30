Rails.application.routes.draw do
  root to: 'welcome#index'

  resources :events

  get '/auth/:provider/callback' => 'sessions#create'
  get '/logout' => 'sessions#destroy', as: :logout
end
