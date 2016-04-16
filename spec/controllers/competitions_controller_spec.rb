require 'rails_helper'

RSpec.describe CompetitionsController do
  context "GET new" do
    it "assings a @competitor and a @challenger" do
      create_list(:art, 2)
      get :new
      expect(assigns(:competition).challenger).to eq assigns(:challenger)
      expect(assigns(:competition).art).to eq assigns(:competitor)
    end

    it "returns ok" do
      create_list(:art, 2)
      get :new
      expect(response.status).to eq 200
    end
    
    it "assings an error message if not enough art are available" do
      get :new
      expect(response.status).to eq 422
      expect(assigns(:error_message)).to eq "We don't have enough art for you to rank.  Check back soon!"
      create(:art)
      get :new
      expect(response.status).to eq 422
      expect(assigns(:error_message)).to eq "We don't have enough art for you to rank.  Check back soon!"
    end
  end
  
  context "POST create" do
    it "assigns a new competition with the given params" do
      art = create(:art)
      challenger = create(:art)
      competition = Competition.create(art: art, challenger: challenger)
      post :create, params: {id: competition.id, winner: 1}
      expect(assigns(:competition).winning_art).to eq challenger
      expect(assigns(:competition).losing_art).to eq art
      expect(assigns(:competition).persisted?).to be true
      expect(response.status).to eq 200
    end
  end
end