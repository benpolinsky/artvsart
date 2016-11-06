class UsersController < ApplicationController
  before_action :authorize_user!

  def show
    user = current_user
    render json: user
  end


  def update
    user = current_user
    if user.update(user_params)
      render json: user
    else
      render json: {errors: user.errors}
    end
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
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :current_password)
  end
end