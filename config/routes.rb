FinalProject::Application.routes.draw do

  resources :sections, only: [:show]
  resources :students, only: [:show, :names]
  # resources :courses, only: [:show]
  resources :commitments, only: [:show]
  resources :teachers, only: [:show, :names]
  resources :search, only: [:index]
  resources :supercourses, only: [:show, :names]
  
  #  get "sections/show"
  #  get "sections/index"
  get "static_pages/home"
  match "contact", to: "static_pages#contact", via: "get"
  match "studentList.json", to: "students#names", via: "get"
  match "teacherList.json", to: "teachers#names", via: "get"
  match "courseList.json", to: "supercourses#names", via: "get"
  #  get "students/index"
  #  get 'students/:id', to: 'students#show'
  #  get "students/", to: 'students#index'

  devise_for :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'static_pages#home'

  namespace :api do
    resources :students
  end

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
