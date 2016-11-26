class ProfileController < ApplicationController
  include ActionController::Serialization
  before_action :authorize_user_or_create_guest!
  
    
  def index

  end
  # probably not the place for this...
  def competitions
    competitions = current_user.judged_competitions.size
    render json: {competition_size: competitions}, status: 200
  end
  
end
