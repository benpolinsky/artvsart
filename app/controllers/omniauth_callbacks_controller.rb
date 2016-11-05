class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      user.confirm if user.confirmed_at.nil?
      sign_in user, store: false
      user.generate_auth_token!
      user.save
      session[:pending_token] = user.auth_token
      render json: user, status: 200
    else
      render json: {errors: user.errors}
    end        
  end
  
  def github 
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      user.confirm if user.confirmed_at.nil?
      sign_in user, store: false
      user.generate_auth_token!
      user.save
      session[:pending_token] = user.auth_token
      render json: user, status: 200
    else
      render json: {errors: user.errors}
    end        
  end
  

end