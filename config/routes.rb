Rails.application.routes.draw do
  devise_for :users

  resources :products, only: [:index, :create, :edit, :update, :destroy] do
      member do
        post :sell
        end
  end
  
  root 'products#index'
end