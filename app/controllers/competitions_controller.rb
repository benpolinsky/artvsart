class CompetitionsController < ApplicationController
  include ActionController::Serialization

  def create
    if @competition = Competition.stage
      render json: {competition: CompetitionSerializer.new(@competition), user: UserSerializer.new(current_user)}
    else
      @error_message = "We don't have enough art for you to rank.  Check back soon!"
      render json: {message: @error_message}, status: 422
    end
  end

  # TODO: refactor 
  def update
    @competition = Competition.includes(:art).find_by(id: params[:id])
    if @competition && current_user.judge(@competition, winner: params[:competition][:winner_id])
      render json: @competition
    elsif @competition.errors
      render json: {competition: {errors: @competition.errors}}, status: 400
    elsif current_user.errors
      render json: {competition: {errors: current_user.errors}}, status: 400
    else
      render status: 404
    end
  end
  
  
end
