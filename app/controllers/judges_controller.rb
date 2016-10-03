class JudgesController < ApplicationController
  include ActionController::Serialization

  def top
    top_judges = User.top_judges
    render json: {top_judges: top_judges}, status: 200
  end
end