class ArtController < ApplicationController
  include ActionController::Serialization
  def new
  end

  def create
    art = Art.new(art_params)
    if art.save
      render json: art, status: 200
    else
      render json: {errors: "Still Need to standardize my errors"}, status: 422
    end
  end

  def edit
  end

  def update
  end

  def show
    art = Art.find(params[:id])
    if art
      render json: art, status: 200
    else
      render json: {errors: "Sorry. No art found."}, status: 404
    end
  end
  
  protected

  def art_params
    params.require(:art).permit(:name, :creator, :description)
  end
    
end