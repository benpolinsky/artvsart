# Refactor into AuthService
class SessionsController < ApplicationController
  include ActionController::Serialization

  def create
    user = User.only_deleted.find_by(email: session_params[:email])
    if user && user.valid_password?(session_params[:password])
      render json: {user: user, deleted_user: true, message: "Looks like you've previously signed up but deleted your account.  Re-enter your email and password below to restore it."}
    else
      user = session_params[:email].present? && User.find_by(email: session_params[:email])
      if user && user.valid_password?(session_params[:password])
        sign_in user, store: false
        user.generate_auth_token!
        user.save
        session[:pending_token] = user.auth_token
        render json: user, status: 200
      else
        render json: {errors: "Invalid email or password!"}, status: 422
      end 
    end
  end
  
  
  def destroy
    user = User.find_by(auth_token: request.headers['Authorization'])
    if user
      user.auth_token = ""
      session[:pending_token] = nil
      user.save
    end
    
    render json: new_guest_user, status: 200
  end
  
  protected
  
  def session_params
    params.permit(:email, :password)
  end
end
