class ResultsController < ApplicationController
  include ActionController::Serialization
  
  def index
    art = Art.leaders
    render json: {
      art_results: {
        top_winners: ArtResultsSerializer.new(art)
      }
    }
  end
end