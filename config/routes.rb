Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }

  resources :users, except: [:index]
  get 'feed', to: 'users#feed'

  resources :dogs do
    member do
      post 'follow', to: 'dogs#follow'
      delete 'unfollow', to: 'dogs#unfollow'
    end
  end

  resources :contents, except: [:index] do
    collection do
      get 'new_post', to: 'contents#new_post'
      get 'new_video', to: 'contents#new_video'
      get 'new_image', to: 'contents#new_image'
    end
  end

  resources :play_dates
  resources :dog_parks do
    member do
      post 'follow', to: 'dog_parks#follow'
      delete 'unfollow', to: 'dog_parks#unfollow'
    end
  end

  resources :comments, except: [:index, :show]
  resources :barks, only: [:new, :create]

  # Defines the root path route ("/")
  root "dogs#index"
end
