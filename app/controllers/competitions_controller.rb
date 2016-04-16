class CompetitionsController < ApplicationController
  include ActionController::Serialization
  def new
    if Art.all.size >= 2
      pick_battle_pair
      @competition = Competition.create(art: @competitor, challenger: @challenger)
      render json: @competition
    else
      @error_message = "We don't have enough art for you to rank.  Check back soon!"
      render json: {message: @error_message}, status: 422
    end
  end
  
  def create
    @competition = Competition.find(params[:id]) 
    if @competition.update(winner: params[:winner].to_i)
      render json: @competition
    else
      render json: {errors: @competition.errors}
    end
  end
  
  
  protected
  
  def pick_battle_pair
    @competitor = Art.all.sample
    @challenger = (Art.all - [@competitor]).sample
  end
end
