Rails.application.routes.draw do
  devise_for :users
  
  # 管理画面
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    resources :articles
    resources :pages
    resources :media
    resource :settings, only: [:show, :edit, :update]
    root 'dashboard#index'  # /admin のルートパス
  end
  
  # フロントエンド
  namespace :site do
    get 'home/index'
    root 'home#index'  # /site のルートパス
  end
  
  # API
  namespace :api do
    namespace :v1 do
      resources :articles
      resources :pages
      resources :media
      resource :settings, only: [:show, :update]
    end
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/") - CMSのフロントページ
  root "site/home#index"
end
