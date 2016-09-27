class SessionsController < ApplicationController
  include ActionController::Serialization
  
  def create
    user = session_params[:email].present? && User.find_by(email: session_params[:email])
    if user && user.valid_password?(session_params[:password])
      sign_in user, store: false
      user.generate_auth_token!
      render json: user, status: 200
    else
      render json: {errors: "Invalid email or password!"}, status: 422
    end 
  end
  
  
  def destroy
    user = User.find(params[:id])
    if user
      user.auth_token = ""
      user.save
    end
    render status: 204
  end
  
  protected
  
  def session_params
    params.permit(:email, :password)
  end
end
