Rails.application.routes.draw do
  devise_for :users

  resources :users, except: [:index]

  resources :dogs do
    member do
      post 'follow', to: 'dogs#follow'
      delete 'unfollow', to: 'dogs#unfollow'
    end
  end

  resources :posts
  resources :videos
  resources :images
  resources :play_dates

  resources :comments, except: [:index, :show]
  resources :barks, except: [:index, :show]

  # Defines the root path route ("/")
  root "dogs#index"
end
