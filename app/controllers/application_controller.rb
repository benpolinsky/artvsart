class ApplicationController < ActionController::API
  
  VALID_GATEWAYS = ['Artsy', 'Discogs', 'Gracenote']
  
  def gateway(source, atts={})
    if source.in? VALID_GATEWAYS
      @gateway ||= "#{source}Gateway".safe_constantize.new(atts)
    end
  end
  
end
