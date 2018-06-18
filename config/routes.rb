Rails.application.routes.draw do
  root to: 'welcome#index'

  resources :events do
    resources :tickets
  end

  get '/auth/:provider/callback' => 'sessions#create'
  get '/logout' => 'sessions#destroy', as: :logout
end
