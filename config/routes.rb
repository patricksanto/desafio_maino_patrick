Rails.application.routes.draw do
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  devise_for :users
  root 'reports#import'
  resources :reports, only: [:new, :create, :show, :index, :destroy]
end
