class RegistrationsController < Devise::RegistrationsController
  include ActionController::Serialization
  respond_to :json
  
  def create
    user = current_user.elevate_to({
      type: "UnconfirmedUser",
      email: user_params[:email],
      password: user_params[:password]
    })

    if user.save
      render json: {user: UserSerializer.new(user), notice: "We've sent you a confirmation email.  Click the link to finish the sign up process."}
    else
      render json: {errors: user.errors}, status: 422
    end
  end
  
  
  protected
  
  def user_params
    params.require(:user).permit(:email, :password)
  end
end