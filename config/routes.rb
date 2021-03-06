Rails.application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'game#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):

  post 'create_game' => 'game#create'
  get 'game/:id/join' => 'game#join'
  post 'game/:id/join' => 'game#join'
  post 'game/:id/deal' => 'game#deal'
  post 'game/:id/award_bid' => 'game#award_bid'
  post 'game/:id/award_trick' => 'game#award_trick'
  post 'game/:id/award_game' => 'game#award_game'
  post 'hand/:hand_id/make_bid', to: 'hand#make_bid'
  post 'hand/:hand_id/play', to: 'hand#play'
  post 'hand/:hand_id/discard', to: 'hand#discard'

  resources :game

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
