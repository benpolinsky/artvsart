class ConfirmationsController < Devise::ConfirmationsController
  def show
    user = User.confirm_by_token(params[:confirmation_token])
    yield user if block_given?
      if user.errors.empty?
        sign_in user, store: false
        render json: {user: UserSerializer.new(user), confirmed: "true"}
      else
        render json: {errors: user.errors}
      end
  end
end