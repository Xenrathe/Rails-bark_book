Rails.application.routes.draw do
  devise_for :users, controllers: { confirmations: 'users/confirmations', sessions: 'users/sessions', registrations: 'users/registrations', omniauth_callbacks: 'users/omniauth_callbacks' }

  resources :users, except: [:index] do
    member do
      patch 'make_primary/:address_id', to: 'users#make_primary', as: :make_primary
      get 'edit_address/:address_id', to: 'users#show', as: :edit_address
      post 'new_address', to: 'users#new_address'
    end
  end
  get 'feed', to: 'users#feed'
  post 'set_location', to: 'users#set_location'

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

  resources :play_dates do
    member do
      post 'attend', to: 'play_dates#attend'
    end
  end
  resources :dog_parks do
    member do
      post 'follow', to: 'dog_parks#follow'
      delete 'unfollow', to: 'dog_parks#unfollow'
    end
  end

  resources :comments, except: %i[index show]
  resources :barks, only: %i[new create]
  resources :address, only: %i[update destroy]

  # Defines the root path route ("/")
  root 'users#feed'
end
