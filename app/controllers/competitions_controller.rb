class CompetitionsController < ApplicationController
  include ActionController::Serialization
  before_action :authorize_user!, except: [:index, :show]
  
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
    if @competition 
      result = current_user.judge(@competition, winner: params[:competition][:winner_id])
      
      if result.try(:errors) && result.errors.any?
        render json: {competition: {errors: result.errors}}, status: 400
      else
        render json: result
      end
    else
      render status: 404
    end
  end
  
  
end
