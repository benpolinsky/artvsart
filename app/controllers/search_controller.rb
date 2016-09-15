class SearchController < ApplicationController
  def index
    begin
      result = gateway(search_params[:source]).search(search_params[:query], search_params[:query_params].to_h)      
      if result.try(:error)
        render json: {error: "Sorry, something went wrong."}
      else      
        render json: {results: result}
      end      
    rescue Faraday::Error::ResourceNotFound => e
      render json: {error: "Not Found"}      
    end
  end
  
  protected
  def search_params
    params.permit(:source, :query, :listing_id, :listing_ids, :search => {}, :query_params => [:artist, :master, :release])
  end
  
end