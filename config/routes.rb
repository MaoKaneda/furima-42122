Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  root to: "items#index"
  
  resources :items, only: [:index, :new, :create, :show, :edit, :update, :destroy]
end
