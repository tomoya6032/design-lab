Rails.application.routes.draw do
  devise_for :users
  
  # 管理画面
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    resources :articles do
      collection do
        post 'fetch_ogp'
        post 'upload_images'
      end
    end
    resources :pages do
      collection do
        post 'fetch_ogp'
        post 'upload_images'
        patch 'update_navigation'
      end
    end
    resources :media
    resources :portfolios do
      delete 'images/:id', to: 'portfolios#destroy_image', as: 'destroy_image'
    end
    resources :jobs do
      delete 'images/:id', to: 'jobs#destroy_image', as: 'destroy_image'
    end
    resources :users, only: [:index, :show, :edit, :update, :destroy]
    resource :settings, only: [:show, :edit, :update]
    get 'theme-customization', to: 'theme_customization#edit'
    patch 'theme-customization', to: 'theme_customization#update'
    root 'dashboard#index'  # /admin のルートパス
  end
  
  # フロントエンド
  namespace :site do
    get 'home/index'
    resources :articles, only: [:index, :show]
    resources :pages, only: [:index, :show]
    resources :jobs, only: [:index, :show]
    root 'home#index'  # /site のルートパス
  end
  
  # 固定ページ用の短縮ルート
  get 'page/:id', to: 'site/pages#show', as: :page
  
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
