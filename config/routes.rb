Rails.application.routes.draw do
  devise_for :users

  resources :users, except: [:index]
  get 'feed', to: 'users#feed'

  resources :dogs do
    member do
      post 'follow', to: 'dogs#follow'
      delete 'unfollow', to: 'dogs#unfollow'
    end
  end

  resources :posts, except: [:index]
  resources :videos, except: [:index]
  resources :images, except: [:index]
  resources :play_dates

  resources :comments, except: [:index, :show]
  resources :barks, except: [:index, :show]

  # Defines the root path route ("/")
  root "dogs#index"
end
