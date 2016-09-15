class ResultsController < ApplicationController
  include ActionController::Serialization
  
  def index
    art = Art.all
    render json: art, serializer: ArtResultsSerializer
  end
end