Rails.application.routes.draw do
  devise_for :users
  mount ActionCable.server => '/cable'

  root to: 'home#index'

  resources :attachments, only: %i[index create] do
    get :results, on: :member
  end

  resources :results, only: %i[index show]
end
