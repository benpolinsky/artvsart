class SearchController < ApplicationController
  before_action :authorize_admin!
  
  def index
    result = gateway(search_params[:source]).search(search_params[:query], search_params[:query_params].to_h)
    if result
      render json: {results: result}
    else      
      render json: {errors: @gateway.errors}
    end      
  end
  
  protected
  
  def search_params
    params.permit(:source, :query, :listing_id, :listing_ids, :search => {}, :query_params => [:artist, :master, :release])
  end
  
end