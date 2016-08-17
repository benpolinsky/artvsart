Rails.application.routes.draw do
  resources :competitions

  scope path: 'api' do
    scope path: 'v1' do
      post 'battle' => 'competitions#create'
      put 'choose' => 'competitions#update'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
