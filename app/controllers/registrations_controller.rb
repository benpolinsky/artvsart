class RegistrationsController < Devise::RegistrationsController
  include ActionController::Serialization
  respond_to :json
  
  def create
    user = User.new(user_params)
    if user.save
      sign_in user, store: false
      render json: user, status: 201
    else
      render json: {errors: user.errors}, status: 422
    end
  end
  
  
  protected
  
  def user_params
    params.require(:user).permit(:email, :password)
  end
end