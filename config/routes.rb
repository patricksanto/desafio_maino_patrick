Rails.application.routes.draw do
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  devise_for :users
  root 'dashboard#index'
  resources :reports, only: [:new, :create, :show]
end
