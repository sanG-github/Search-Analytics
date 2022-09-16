Rails.application.routes.draw do
  devise_for :users
  mount ActionCable.server => '/cable'

  root to: 'home#index'
  resources :results, only: %i[index show]
  resources :attachments, only: %i[index create] do
    get :results, on: :member
  end

  draw(:external_apis)
end
