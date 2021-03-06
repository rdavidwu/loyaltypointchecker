DemoApp::Application.routes.draw do
  #resources :users
  get '/' => 'loyalty_account#add_account'

  get 'myloyaltytracker' => 'loyalty_account#show'

  get 'addloyaltyaccount' => 'loyalty_account#add_account'
  post 'addloyaltyaccount' => 'loyalty_account#connect'

  get 'checkloyaltyaccount' => 'loyalty_account#add_account'

  get 'checkloyaltyprogress' => 'loyalty_account#check_done_scraping'

  match '/404' => 'errors#not_found', via: [:get, :post]
  match '/422' => 'errors#server_error', via: [:get, :post]
  match '/500' => 'errors#server_error', via: [:get, :post]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
