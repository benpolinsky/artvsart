class ResultsController < ApplicationController
  include ActionController::Serialization
  
  def index
    art = Art.all
    render json: {
      art_results: {
        top_winners: ArtResultsSerializer.new(art.by_winning_percentage)
      }
    }
  end
end