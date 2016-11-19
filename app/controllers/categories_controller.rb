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
    if category.saves_with_parent_category?(category_params)
      render json: {category: CategorySerializer.new(category)}, status: 200
    else
      render json: {category: CategorySerializer.new(category), errors: category.errors}, status: 200      
    end
  end
  
  def create
    category = Category.new
    if category.saves_with_parent_category?(category_params)
      render json: {category: CategorySerializer.new(category)}, status: 200
    else
      render json: {category: CategorySerializer.new(category), errors: category.errors}, status: 200      
    end
  end
  
  def destroy
    category = Category.find(params[:id])
    if category.arts.any?
      render json: {errors: ["Sorry, you can't delete a category that's still referenced by art."]}, status: 422
    elsif category.destroy
      render json: {category: CategorySerializer.new(category), category_deleted: true}, status: 200
    else
      render json: {errors: ["Sorry. Not found."]}, status: 404
    end
  end
  
  private
  def category_params
    params.require(:category).permit(:name, :color, :parent_category)
  end
end