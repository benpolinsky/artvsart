Rails.application.routes.draw do


  devise_for :users
  scope path: 'api' do
    scope path: 'v1' do
      resources :competitions, :sessions
      post 'users/sign_in' => 'sessions#create'
      delete 'users/sign_out' => 'sessions#destroy'
      resources :art do
        post 'import', on: :collection
      end
       
      get 'results' => 'results#index' 
      get 'search_source' => 'search#index'
      get 's3/sign' => 's3#sign'
      
      get 'hi' => "application#hi"
      
      root to: 'application#hi'
    end
    
  end
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
