Rails.application.routes.draw do
  devise_for :users
  
  # 管理画面
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    resources :categories
    resources :tags
    resources :articles do
      collection do
        post 'fetch_ogp'
        post 'upload_images'
        patch 'bulk_action'
      end
    end
    resources :pages do
      collection do
        post 'fetch_ogp'
        post 'upload_images'
        patch 'update_navigation'
        patch 'bulk_action'
      end
    end
    resources :media do
      collection do
        get :select
      end
    end
    resources :portfolios do
      delete 'images/:id', to: 'portfolios#destroy_image', as: 'destroy_image'
    end
    resources :jobs do
      delete 'images/:id', to: 'jobs#destroy_image', as: 'destroy_image'
    end
    resources :job_applications, only: [:index, :show, :destroy] do
      member do
        patch :update_status
      end
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
    resources :portfolios, only: [:index, :show]
    resources :jobs, only: [:index, :show] do
      resources :job_applications, only: [:new, :create, :show] do
        member do
          get :confirm
          post :confirm, action: :create_confirmed
        end
      end
    end
    resources :contacts, only: [:new, :create, :show] do
      member do
        get :thank_you
      end
    end
    get 'search', to: 'search#index', as: :search
    root 'home#index'  # /site のルートパス
  end
  
  # 問い合わせフォーム用の短縮ルート
  get 'contact', to: 'site/contacts#new', as: :contact
  post 'contact', to: 'site/contacts#create'
  get 'contact/:id/thank_you', to: 'site/contacts#thank_you', as: :thank_you_contact
  get 'contact/test', to: 'site/contacts#test', as: :test_contact
  get 'contact/debug', to: 'site/contacts#debug', as: :debug_contact
  get 'contact/simple', to: 'site/contacts#simple', as: :simple_contact
  
  # 固定ページ用の短縮ルート
  get 'page/:id', to: 'site/pages#show', as: :page
  
  # 検索用の短縮ルート
  get 'search', to: 'site/search#index', as: :search
  
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
