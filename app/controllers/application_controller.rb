class ApplicationController < ActionController::API
  # include CanCan::ControllerAdditions
  include ActionController::Serialization
  VALID_GATEWAYS = ['Artsy', 'Discogs', 'Gracenote', "Philart", 'IMDB', "HarvardArt"]

  
  def hi
    render(json: {user: serializer_for_current_user})
  end
  
  def gateway(source, atts={})
    if source.in? VALID_GATEWAYS
      @gateway ||= "#{source}Gateway".safe_constantize.new(atts)
    end
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
    guest_user = GuestUser.create
    session[:pending_token] = guest_user.auth_token
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
  
end
