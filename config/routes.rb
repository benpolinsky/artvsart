Rails.application.routes.draw do


  scope path: 'api' do
    scope path: 'v1' do
      resources :competitions, :art
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
