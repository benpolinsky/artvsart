class ArtController < ApplicationController
  before_action :authorize_admin!, except: [:show]
  
  include ActionController::Serialization
  
  def index
    render json: {art: Art.ordered}
  end
  
  
  def new
  end

  def create
    art = Art.new(art_params)
    if art.saves_with_category_name?(art_params)
      render json: {art: ArtSerializer.new(art)}, status: 200
    else
      render json: {errors: "Still Need to standardize my errors"}, status: 422
    end
  end
  
  def import
    source_gateway = gateway(params[:source], {listing_id: params[:id]})
    importer = ArtImporter.new(source_gateway)
    importer.import
    byebug
    render json: {result: 'imported!', listing_id: params[:id]}, status: 200
  end

  def edit
  end

  def update
    art = Art.find(params[:id])
    if art.saves_with_category_name?(art_params)
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
    params.require(:art).permit(:name, :creator, :description, :image, :creation_date, 
                                :source, :category, :category_name, :source_link, :status)
  end
    
end
