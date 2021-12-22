Rails.application.routes.draw do
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root "pages#index"
  get 'pages', to: 'pages#index'
  
  devise_for :users
  
  resources :keywords do
    collection do
      get 'new_upload'
      post 'bulk_upload'
      get 'bulk_upload',to: 'keywords#new_upload'
    end
  end 

end
