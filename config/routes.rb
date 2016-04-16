Rails.application.routes.draw do
  resources :competitions do
    collection do
      get 'new'
    end
  end

  scope path: 'api' do
    scope path: 'v1' do
      get 'battle' => 'competitions#new'
      post 'choose' => 'competitions#create'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
