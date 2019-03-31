class CompetitionsController < ApplicationController
  include ActionController::Serialization
  
  before_action :authorize_user_or_create_guest!, except: [:index, :show]
  
  def show
    competition = Competition.judged.find_by(id: params[:id])
    if competition
      render json: {competition: CompetitionSerializer.new(competition)}
    else
      render json: {error: "Competition not found"}, status: 404
    end
  end
  
  def show_master
    competition = Competition.find_master(id: params[:id])
    if competition
      render json: {competition: MasterCompetitionSerializer.new(competition)}
    else
      render json: {error: "Competition not found"}, status: 404
    end
  end
  
  def create
    if competition = Competition.stage(current_user)
      render json: {competition: CompetitionSerializer.new(competition), user: UserSerializer.new(current_user)}
    else
      error_message = "We don't have enough art for you to rank.  Check back soon!"
      render json: {error: error_message} , status: 422
    end
  end

  # TODO: refactor 
  def update
    if current_user.type == "BotUser"
      render(json: {hi: "bot"} ) and return
    end
    competition = Competition.includes(:art).find_by(id: params[:id])
    if competition 
      result = current_user.judge(competition, winner: params[:competition][:winner_id])
      
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
