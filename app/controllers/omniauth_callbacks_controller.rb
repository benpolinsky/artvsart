class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    user = User.only_deleted.find_by(email: request.env['omniauth.auth'].info.email)
    if user
      render json: {user: user, message: "Looks like you've previously signed up but deleted your account.  Re-enter your email and password below to restore it."}
    else
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