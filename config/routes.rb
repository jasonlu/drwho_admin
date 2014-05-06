DrwhoAdmin::Application.routes.draw do

  

  #mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, :controllers => { :registrations => "admin_registrations", :sessions => "admin_sessions" }  
  get "users/search", :to => 'users#search', :as => :search_user
  get "admins/search", :to => 'admins#search', :as => :search_admin
  resources :users
  resources :admins
  resources :categories
  resources :ads
  resources :studies

  get "study/set_start_day", :to => 'studies#set_start_day', :as => :set_start_day
  patch "study/update_start_day/(:study_id)", :to => 'studies#update_start_day', :as => :update_start_day

  get "records/", :to => 'records#index', :as => :records
  get "record/:study_id", :to => 'records#show', :as => :record


  get "records/wrong_list/question/:course_item_id", :to => 'records#wrong_list_question', :as => :record_wrong_list_question
  get "records/wrong_lists", :to => 'records#wrong_list_index', :as => :record_wrong_lists
  get "records/wrong_list/:study_id", :to => 'records#wrong_list_show', :as => :record_wrong_list
  

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
  get "mfg/edit", :to => 'home#edit', :as => :mfg
  patch "mfg/update", :to => 'home#update'

  get "uploads", :to => 'upload_files#index'
  post "uploads", :to => 'upload_files#create'
  resources :upload_files
  
  root :to => "home#dashboard"

end
