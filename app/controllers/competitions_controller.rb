class CompetitionsController < ApplicationController
  include ActionController::Serialization

  def create
    if Art.all.size >= 2
      pick_battle_pair
      @competition = Competition.create(art: @competitor, challenger: @challenger)
      render json: @competition
    else
      @error_message = "We don't have enough art for you to rank.  Check back soon!"
      render json: {message: @error_message}, status: 422
    end
  end
  
  def update
    @competition = Competition.find_by(id: params[:competition][:id]) 
    if @competition && @competition.select_winner(params[:competition][:winner_id].to_i)
      render json: @competition
    elsif @competition
      render json: {competition: {errors: @competition.errors}}
    else
      render status: 404
    end
  end
  
  
  protected
  
  def pick_battle_pair
    # Replace with some fun randomization or algo
    @competitor = Art.all.sample 
    @challenger = (Art.all - [@competitor]).sample
  end
  
end
