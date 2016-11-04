class PasswordsController < Devise::PasswordsController
  skip_before_action :require_no_authentication, only: [:edit, :update]
  append_before_action :assert_reset_token_passed, only: :edit
  
  def new
    user = User.find_by(email: params[:email])
    user.send_reset_password_instructions if user
    render(json: {notice: "We've sent password instructions to that email if it was found!"})
  end

end