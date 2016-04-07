Rails.application.routes.draw do
  get 'arts/new'

  get 'arts/create'

  get 'arts/edit'

  get 'arts/update'

  get 'arts/show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
