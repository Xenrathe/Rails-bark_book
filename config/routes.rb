Rails.application.routes.draw do
  devise_for :users
  resources :dogs

  get 'flickr', to: 'dogs#flickr'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "dogs#index"
end
