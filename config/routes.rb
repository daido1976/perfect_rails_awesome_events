Rails.application.routes.draw do
  root to: 'welcome#index'

  resource :user, only: :destroy do
    get 'retire'
  end

  resources :events do
    resources :tickets, only: [:create, :destroy]
  end

  get '/auth/:provider/callback' => 'sessions#create'
  get '/logout' => 'sessions#destroy', as: :logout
end
