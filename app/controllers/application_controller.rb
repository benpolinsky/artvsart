class ApplicationController < ActionController::API
  VALID_GATEWAYS = ['Artsy', 'Discogs', 'Gracenote', "Philart", 'IMDB', "HarvardArt"]
  # before_action :sleepy

  
  def gateway(source, atts={})
    if source.in? VALID_GATEWAYS
      @gateway ||= "#{source}Gateway".safe_constantize.new(atts)
    end
  end
  
  
  # Override Devise to not query session
  def current_user
    @current_user ||= User.find_by(auth_token: request.headers['Authorization'])
  end
  
end
