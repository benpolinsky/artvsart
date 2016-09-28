class CompetitionsController < ApplicationController
  include ActionController::Serialization

  def create
    if @competition = Competition.stage
      render json: @competition
    else
      @error_message = "We don't have enough art for you to rank.  Check back soon!"
      render json: {message: @error_message}, status: 422
    end
  end
  
  def update
    @competition = Competition.includes(:art).find_by(id: params[:id]) 
    if @competition && @competition.select_winner(params[:competition][:winner_id].to_i)
      render json: @competition
    elsif @competition
      render json: {competition: {errors: @competition.errors}}
    else
      render status: 404
    end
  end
  
  
end
