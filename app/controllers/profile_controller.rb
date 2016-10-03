class ProfileController < ApplicationController
  before_filter :authorize_user!
  
  def index

  end
  # probably not the place for this...
  def competitions
    competitions = current_user.judged_competitions
    render json: competitions, status: 200
  end
  
end
