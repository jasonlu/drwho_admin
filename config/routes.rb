DrwhoAdmin::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, :controllers => { :registrations => "admin_registrations", :sessions => "admin_sessions" }  
  
  get "users/search", :to => 'users#search', :as => :search_user
  get "admins/search", :to => 'admins#search', :as => :search_admin
  resources :users
  resources :admins
  
  resources :ads  
  match "study/set_start_day/(:user_id)", :to => 'studies#set_start_day', via: [:get, :post, :patch], :as => :set_start_day
  match "study/record/(:user_id)", :to => 'studies#record', via: [:get, :post], :as => :study_record
  match "study/wrong_list/(:user_id)", :to => 'studies#wrong_list', via: [:get, :post], :as => :study_wrong_list  
  

  get "orders/new", :to => 'orders#edit', :as => :new_order
  get "order/:id", :to => 'orders#show', :as => :user_order
  get "order/:id/edit", :to => 'orders#edit', :as => :edit_admin_order
  
  post "order/:id", :to => 'orders#create'
  patch "order/:id/quickpaid", :to => 'orders#quickpaid', :as => :order_paid
  patch "order/:id", :to => 'orders#update'  
  delete "orders/:id", :to => 'orders#delete'
  resources :orders

  patch "course/:id/hide", :to => 'courses#hide', :as => :hide_course
  patch "course/:id/unhide", :to => 'courses#unhide', :as => :unhide_course
  resources :courses
  resources :messages
  resources :pages
  resources :news

  get "config", :to => 'site_configs#index', :as => :site_configs
  patch "config", :to => 'site_configs#update'
  get "mfg", :to => 'home#edit', :as => :mfg
  patch "mfg", :to => 'home#update'
  
  root :to => "home#dashboard"

end
