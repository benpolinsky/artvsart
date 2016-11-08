class UsersController < ApplicationController
  before_action :authorize_user!, except: [:restore]

  def show
    render json: current_user
  end


  def update
    if current_user.update(user_params)
      render json: user
    else
      render json: {errors: user.errors}
    end
  end
  
  def change_password
    if current_user.update_with_password(user_params)
      render json: user
    else
      render json: {errors: "Your original password is incorrect."}
    end
  end
  
  def destroy
    if current_user.destroy
      render json: {user: GuestUserSerializer.new(new_guest_user), notice: "Sorry to see you go... Take care!"}
    else
      render json: {errors: user.errors}
    end
  end
  
  def restore
    user = User.only_deleted.find_by(email: user_params[:email])

    if user && user.valid_password?(user_params[:password])
      user.restore
      render json: {user: UserSerializer.new(user), notice: "Excellent!  You're back up and running."}
    else
      render json: {errors: "Sorry! Please check the email and password you've entered." }
    end
  end
  
  protected
  
  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :current_password)
  end
end