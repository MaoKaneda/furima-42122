Rails.application.routes.draw doAdd commentMore actions
  devise_for :users
  root to: "items#index"

end