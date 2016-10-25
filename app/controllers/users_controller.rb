class UsersController < ApplicationController
  before_action :authorize_user!

  def show
    current_user
    render json: current_user
  end


  def update
    current_user.update(user_params)
    render json: current_user
  end
  
  def change_password
    user = current_user
    if current_user.update_with_password(user_params)
      render json: user
    else
      render json: {errors: "Your original password is incorrect."}
    end
  end
  
  protected
  
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
  end
end