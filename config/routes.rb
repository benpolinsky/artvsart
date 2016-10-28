Rails.application.routes.draw do
  scope path: 'api' do
    scope path: 'v1' do
      devise_for :users, controllers: {registrations: 'registrations', omniauth_callbacks: 'omniauth_callbacks', sessions: "sessions"}, defaults: {format: :json}
      resources :competitions, :sessions, :categories
      
      resources :art do
        post 'import', on: :collection
      end
      
      post 'users/sign_in' => 'sessions#create'
      delete 'users/sign_out' => 'sessions#destroy'
      resource :user do
        put :change_password
      end
      get 'user/competitions' => 'profile#competitions'
      get 'ranked_users' => 'results#ranked_users'
      
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
