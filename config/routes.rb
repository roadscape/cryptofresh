Rails.application.routes.draw do

  resources :products do
    member do
      post "order" => 'products#order', :as => :order
      get "new"    => 'products#new',   :as => :new_child
    end
    collection do
      get 'report'
      post 'subscribe'
    end
  end

  resources :orders do
    member do
      get "status"
      get "download"
    end
  end

  root 'products#index'

end
