class ResultsController < ApplicationController
  include ActionController::Serialization
  
  def index
    art = Art.all
    render json: {art_results: 
      {
        overall_winner: ArtSerializer.new(Art.overall_winner),
        overall_loser: ArtSerializer.new(Art.overall_loser),
        top_winners: ArtResultsSerializer.new(art.by_wins),
        top_losers: ArtResultsSerializer.new(art.by_losses)
      }
    }
  end
end