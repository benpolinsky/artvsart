# refactor into AuthService
class RegistrationsController < Devise::RegistrationsController
  include ActionController::Serialization
  respond_to :json
  
  def create
    user = User.only_deleted.find_by(email: user_params[:email])
    if user && user.valid_password?(user_params[:password])
      render json: {user: UserSerializer.new(user), deleted_user: true, message: "Looks like you've previously signed up but deleted your account.  Re-enter your email and password below to restore it."}
    else
      user = current_user.elevate_to({
        type: "UnconfirmedUser",
        email: user_params[:email],
        password: user_params[:password]
      })
      if user.save
        render json: {user: UserSerializer.new(user), notice: 
          "We've sent you a confirmation email.  Click the link to finish the sign up process."}
      else
        render json: {errors: user.errors}, status: 422
      end
    end
  end
  
  
  protected
  
  def user_params
    params.require(:user).permit(:email, :password)
  end
end