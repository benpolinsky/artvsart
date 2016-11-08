# Yeah, getting outta control... time to refactor to an AuthService
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    user = User.only_deleted.find_by(email: request.env['omniauth.auth'].info.email)
    if user
      if params[:restoring] == 'true'
        user.restore
        render json: {user: UserSerializer.new(user), notice: "Excellent!  You're back up and running."}
      else
        render json: {user: UserSerializer.new(user), deleted_user: true, message: "Looks like you've previously signed up but deleted your account.  Reauthorize with Facebook to restore it."}
      end
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