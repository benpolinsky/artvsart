Rails.application.routes.draw do

  devise_for :users, controllers: {registrations: 'registrations', omniauth_callbacks: 'omniauth_callbacks'}, defaults: {format: :json}

  scope path: 'api' do
    scope path: 'v1' do
      
      resources :competitions, :sessions
      
      resources :art do
        post 'import', on: :collection
      end
      
      post 'users/sign_in' => 'sessions#create'
      delete 'users/sign_out' => 'sessions#destroy'
      
      get 'user/competitions' => 'profile#competitions'
      
      get 'top_judges' => 'judges#top'
      
      get 'results' => 'results#index' 

      get 'search_source' => 'search#index'

      get 's3/sign' => 's3#sign'

      get 'profile' => 'profile#index'
      
      get 'hi' => "application#hi"
      
      root to: 'application#hi'
    end    
  end

end
