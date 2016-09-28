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
  
  
  # Override Devise to not query session
  def current_user
    @current_user ||= if user_token_present?
      User.find_by(auth_token: request.headers['Authorization'])
    else
      GuestUser.create
    end
  end
  
  def authorize_user!
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
  
  def user_token_present?
    request.headers['Authorization'].present?
  end
  
end
