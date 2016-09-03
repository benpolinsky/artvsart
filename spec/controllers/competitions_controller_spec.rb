require 'rails_helper'

RSpec.describe CompetitionsController do
  context "POST create" do
    it "assigns a @competitor and a @challenger" do
      create_list(:art, 2)
      post :create
      expect(assigns(:competition)).to_not be_nil
    end

    it "returns ok" do
      create_list(:art, 2)
      post :create
      expect(response.status).to eq 200
    end
    
    it "assings an error message if not enough art are available" do
      post :create
      expect(response.status).to eq 422
      expect(assigns(:error_message)).to eq "We don't have enough art for you to rank.  Check back soon!"
      create(:art)
      post :create
      expect(response.status).to eq 422
      expect(assigns(:error_message)).to eq "We don't have enough art for you to rank.  Check back soon!"
      create(:art)
      post :create
      expect(response.status).to eq 200
    end
  end
  
  context "PUT update/:id" do
    it "assigns a new competition with the given params" do
      art = create(:art)
      challenger = create(:art)
      competition = Competition.create(art: art, challenger: challenger)
      put :update, params: {id: competition.id, competition: {winner_id: challenger.id}}
      expect(assigns(:competition).winning_art).to eq challenger
      expect(assigns(:competition).losing_art).to eq art
      expect(assigns(:competition).persisted?).to be true
      expect(response.status).to eq 200
    end
  end
end