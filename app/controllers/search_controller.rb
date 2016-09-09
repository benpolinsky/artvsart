class SearchController < ApplicationController
  VALID_GATEWAYS = ['Artsy', 'Discogs', 'Gracenote']
  def index
    begin
      result = gateway.search(search_params[:query], search_params[:query_params].to_h)      
      render json: {results: result}      
    rescue Faraday::Error::ResourceNotFound => e
      render json: {error: "Not Found"}      
    end
  end
  
  protected
  def search_params
    params.permit(:source, :query, :listing_id, :listing_ids, :search => {}, :query_params => [:artist, :master, :release])
  end
  
  def gateway
    if search_params[:source].in? VALID_GATEWAYS
      @gateway ||= "#{search_params[:source]}Gateway".safe_constantize.new
    end
  end
end