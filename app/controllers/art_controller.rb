class ArtController < ApplicationController
  before_action :authorize_admin!, except: [:index, :show]
  
  include ActionController::Serialization
  
  def index
    render json: {
      total_pieces_of_art_judged: Art.has_battled.size,
      total_pieces_of_art_in_catalog: Art.count,
      total_competitions: Competition.judged.size
    }
  end
  
  
  def new
  end

  def create
    art = Art.new(art_params)
    if art.saves?(art_params)
      render json: {art: ArtSerializer.new(art)}, status: 200
    else
      render json: {errors: "Still Need to standardize my errors"}, status: 422
    end
  end
  
  def import
    source_gateway = gateway(params[:source], {listing_id: params[:id]})
    importer = ArtImporter.new(source_gateway)
    importer.import
    render json: {result: 'imported!', listing_id: params[:id]}, status: 200
  end

  def edit
  end

  def update
    art = Art.find(params[:id])
    if art.saves?(art_params)
      render json: {art: ArtSerializer.new(art)}, status: 200
    else
      render json: {errors: art.errors}, status: 422
    end
  end

  def show
    art = Art.find(params[:id])
    if art
      render json: {art: ArtSerializer.new(art)}, status: 200
    else
      render json: {errors: "Sorry. No art found."}, status: 404
    end
  end
  
  protected

  def art_params
    params.require(:art).permit(:name, :creator, :description, :image, :creation_date, :source, :category, :category_name)
  end
    
end
