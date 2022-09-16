namespace :api do
  namespace :v1, defaults: { format: :json } do
    devise_for :users, controllers: { sessions: 'api/v1/sessions' }

    resources :attachments, only: %i[create]
    resources :results, only: %i[index show] do
      get :keywords, on: :collection
    end
  end
end
