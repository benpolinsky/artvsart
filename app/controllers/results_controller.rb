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
  
  def ranked_users
    users = User.ranked_judges.limit(50)
    render json: users, each_serializer: RankedUserSerializer, status: 200
  end
end