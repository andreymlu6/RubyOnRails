Gistapp::Application.routes.draw do

  get "follow_activity/follow"
  get "follow_activity/unfollow"
  get "follow_activity/update_follower"

  get "profiles/show"
 as :user do
    get '/register', to: 'devise/registrations#new',via: :get, as: :register
    get '/login', to: 'devise/sessions#new', via: :get, as: :login
    get '/logout', to: 'devise/sessions#destroy', via: :delete, as: :logout
  end

  devise_for :users,  :controllers => {:omniauth_callbacks => 'users/omniauth_callbacks'}  do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end

  resources :users

  as :user do
    get '/login' => 'devise/sessions#new', as: :new_user_session
    post '/login' => 'devise/sessions#create', as: :user_session
    delete '/logout' => 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :votes, :only => [:create]
  resources :comments, :only => [:create, :index] do
    get :new_child_comment, on: :member
    post :create_child_comment, on: :member
    get :up_vote, :member
  end

  resources :user_friendships do
    member do
      put :accept
  end
end

  resources :statuses do
    get 'vote', on: :member
    post 'vote', on: :member
  end
  get 'feed', to: 'statuses#index', as: :feed
  root to: 'statuses#index'

  get '/:id', to: 'profiles#show', as: 'profile'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
