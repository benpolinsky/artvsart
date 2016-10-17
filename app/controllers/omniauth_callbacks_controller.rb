class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      sign_in user, store: false
      user.generate_auth_token!
      user.save
      session[:pending_token] = user.auth_token
      render json: user, status: 200
    end        
  end
  

end