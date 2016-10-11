class CategoriesController < ApplicationController
  include ActionController::Serialization
  before_action :authorize_admin!
  
  def index
    categories = Category.all
    render json: {categories: CategoriesSerializer.new(categories)}, status: 200
  end
  
  def show
    category = Category.find(params[:id])
    render json: {category: CategorySerializer.new(category)}, status: 200
  end
  
  def update
    category = Category.find(params[:id])
    if category.update_attributes(category_params)
      render json: {category: CategorySerializer.new(category)}, status: 200
    else
      render json: {category: CategorySerializer.new(category), errors: category.errors}, status: 200      
    end
  end
  
  def create
    category = Category.new(category_params)
    if category.save
      render json: {category: CategorySerializer.new(category)}, status: 200
    else
      render json: {category: CategorySerializer.new(category), errors: category.errors}, status: 200      
    end
  end
  
  private
  def category_params
    params.require(:category).permit(:name, :color)
  end
end