Rails.application.routes.draw do
  devise_for :users
  mount ActionCable.server => '/cable'

  root to: 'home#index'
  resources :results, only: %i[index show] do
    get :preview, on: :member
  end
  resources :attachments, only: %i[index create] do
    get :results, on: :member
  end


  draw(:external_apis)
end
