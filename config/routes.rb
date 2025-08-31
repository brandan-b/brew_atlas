Rails.application.routes.draw do
  root "breweries#index"
  resources :breweries, only: [:index, :show]
  resources :countries, only: [:index, :show]
  resources :tags, only: [:index, :show]
  get "about", to: "pages#about"
end
