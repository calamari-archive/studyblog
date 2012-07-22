StudyBlog::Application.routes.draw do

  # TODO: Clean up the routes using member do...end (but write tests before that)
  scope '/studies/:study_id' do
    resources :groups
    post '/activate' => "studies#activate", :as => "activate_study"
    get  '/assign'   => "studies#assign",   :as => "assign_study"
    post '/assign'   => "studies#assign",   :as => "assign_study"
  end

  resources :groups, :except => [:show] do
    resources :topics

    match '/startpage/edit'    => "groups#edit_startpage",      :as => "edit_startpage"
    match '/blog'              => "blogs#show",                 :as => "blog"
    get '/timeline'            => "groups#timeline",            :as => "timeline"
    get '/summary'             => "groups#summary",             :as => "summary"

    # module stuff:
    get '/module/:module_type/new'      => "modules#new",       :as => "new_module"
    post '/module/:module_type/new'     => "modules#create"
  end

  scope '/groups' do
    get '/:group_id/participants/new/'  => "users#new_participant",     :as => "new_participant"
    post '/participants/create/'        => "users#create_participant",  :as => "create_participant"
    delete '/participants/destroy/:id'  => "users#destroy_participant", :as => "delete_participant"
  end

  resources :studies do
    resources :mailings

    post '/mailings/load'   => "mailings#load",   :as => "load_mailing"
  end

  resources :mailings do
    member do
      match :save, :method => [:get, :post]
    end
  end

  scope '/studies/:study_id' do
    get '/spectators/new/'          => "users#new_spectator",     :as => "new_spectator"
    post '/spectators/create/'      => "users#create_spectator",  :as => "create_spectator"
  end
  delete '/spectators/destroy/:id'  => "users#destroy_spectator", :as => "delete_spectator"

#  resources :mailings

  match 'login'  => "user_sessions#new"
  match 'logout' => "user_sessions#destroy"

  resources :user_sessions

#  scope '/users/:id' do
#    match '/reactivate' => "users#reactivate", :as => "reactivate_user"
#    match '/deactivate' => "users#deactivate", :as => "deactivate_user"
#  end

  resources :users do
    member do
      get :reactivate
      get :deactivate
    end
    resources :private_messages
  end
  match '/setup'   => "users#setup",   :as => "setup_user", :method => [:get, :post]
  match '/profile' => "users#profile", :as => "profile",    :method => [:get, :post]

  resources :conversations do
    member do
      get '/reply' => "conversations#reply", :as => "reply"
    end
  end

  resources :private_messages do
    get '/reply'                  => "private_messages#reply",        :as => "reply"
  end

  get '/private_messages/conversation/:user_id'  => "private_messages#conversation", :as => "private_message_conversation"

  get '/help'      => "help#index", :as => "help"
  post '/help'     => "help#create_pm", :as => "help"


  resources :blogs do
    resources :blog_entries

    get  '/topic/:topic_id/module'      => "modules#show",         :as => "module"
    post '/topic/:topic_id/module'      => "modules#answer",       :as => "answer_module"

    post '/image' => "blogs#add_image", :as => "image"
  end

  resources :blog_entries do
    resources :comments
  end

  get '/ended' => "startpage#ended", :as => "study_ended"

  root :to => "startpage#index"

  # If user gets here, the page does not exist, so deal with it
  match '*a' => "application#render_404"

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
