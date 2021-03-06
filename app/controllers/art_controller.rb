class ArtController < ApplicationController
  before_action :authorize_admin!, except: [:show]
  
  include ActionController::Serialization
  
  def index
    if params[:search]
      art = Art.ordered.search(params[:search]).page(params[:page])
    else
      art = Art.ordered.page(params[:page])
    end
    render json: {art: art, pages: pagination_for(art), search: params[:search], category_counts: Category.by_art_count}
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
    response = importer.import
    if response
      render json: {result: 'imported!', listing_id: params[:id], new_art: response}, status: 200
    else
      render json: {listing_id: params[:id], errors: importer.errors}, status: 422
    end


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
  
  def update_status
    art = Art.find(params[:id])
    if art.update_attribute(:status, params[:status])
       render json: {art: ArtSerializer.new(art)}, status: 200
    else
       render json: {errors: art.errors}, status: 422
    end
  end
  
  def toggle_many
    ids = params[:art_ids]
    status = params[:status]
    art = Art.where(id: ids) 
    
    
    if art.update_all(status: status)
      render json: {art: art}
    else
      render json: {errors: art.errors}
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
  
  def destroy
    art = Art.find(params[:id])
    if art && art.destroy
      render json: {art: ArtSerializer.new(art), art_deleted: true}, status: 200
    else
      render json: {errors: "Sorry. No art found."}, status: 404
    end
  end
  
  protected

  def art_params
    params.require(:art).permit(:name, :creator, :description, :image, :creation_date, 
                                :source, :category, :category_name, :source_link, :status)
  end
  
  def pagination_for(collection)
    {
      current_page:  collection.current_page,
      next_page:     collection.next_page,
      prev_page:     collection.prev_page,
      total_pages:   collection.total_pages,
      limit_value:   collection.limit_value,
      offset_value:  collection.offset_value,
      first_page:    collection.first_page?,
      last_page:     collection.last_page?,
      total_count:   collection.total_count
    }
  end
    
end
