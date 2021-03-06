class ApplicationController < ActionController::API
  require 'browser'
  # include CanCan::ControllerAdditions
  include ActionController::Serialization
  

  
  def hi
    render(json: {user: serializer_for_current_user})
  end
  
  def gateway(source, atts={})
    source_gateway = VALID_GATEWAYS[source]
    @gateway ||= source_gateway.safe_constantize.new(atts)
  end
  
  def current_user
    if user_token_present?
      user = User.find_by(auth_token: user_token)
      user ? user : new_guest_user
    else
      new_guest_user
    end    
  end
  
  def new_guest_user
    if bot_user_present?
      guest_user = BotUser.new
    else      
      guest_user = GuestUser.new
      guest_user.skip_confirmation!
      session[:pending_token] = guest_user.auth_token
      guest_user.save
    end
    guest_user
  end
  
  def authorize_user!
    render(json: {errors: "Unauthorized!"}, status: 422) unless user_present?
  end
  
  def authorize_user_or_create_guest!
    render(json: {errors: "Unauthorized!"}, status: 422) unless current_user
  end
  
  def authorize_admin!
    render(json: {errors: "Unauthorized!"}, status: 422) unless current_user.try(:admin?)
  end

  
  private
  
  def serializer_for_current_user
    if current_user.is_a? GuestUser
      GuestUserSerializer.new(current_user)
    else
      UserSerializer.new(current_user)
    end
  end
  
  # Clearly these user_* and user_token_* methods should be extracted to...
  # a) Token class?
  # b) Auth module/class?
  
  
  def user_present?
    user_token_present? && User.find_by(auth_token: user_token)
  end
  
  def user_token_present?
    (request.headers['Authorization'].present? && request.headers['Authorization'] != 'undefined') ||
    user_token_just_issued?
  end
  
  def user_token_just_issued?
    session[:pending_token].present?
  end
  
  def user_token
    if request.headers['Authorization'].present? && request.headers['Authorization'] != 'undefined'
       request.headers['Authorization']
    else
      session[:pending_token]
    end
  end
  
  
  def bot_user_present?
    browser = Browser.new(request.user_agent)
    browser.bot? && !browser.bot.search_engine?
  end
end
