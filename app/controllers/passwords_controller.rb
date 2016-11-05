class PasswordsController < Devise::PasswordsController
  skip_before_action :require_no_authentication, only: [:edit, :update]
  append_before_action :assert_reset_token_passed, only: :edit
  
  def new
    user = User.find_by(email: params[:email])
    user.send_reset_password_instructions if user
    render(json: {notice: "We've sent password instructions to that email if it was found!"})
  end
  
  def update
    user = User.reset_password_by_token(resource_params)
    if user.errors.empty?
      user.unlock_access! if unlockable?(user)
      if Devise.sign_in_after_reset_password
        sign_in(:user, user)
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      render(json: {user: UserSerializer.new(user), notice: "Great!  You're signed in."})
    else
      set_minimum_password_length
      render(json: {errors: user.errors, notice: "Sorry, check the form for errors."})
    end
  end

end