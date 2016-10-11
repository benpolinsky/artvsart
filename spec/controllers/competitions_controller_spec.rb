require 'rails_helper'

# I don't want to be forced to use instance variables 
# just so I can test them using assigns(:foo)

# Aside from that, I'm pretty much testing everything
# else in my request specs...

RSpec.describe CompetitionsController do
  context "POST create" do
    it "returns ok" do
      create_list(:art, 2)
      post :create
      expect(response.status).to eq 200
    end
    
    it "assings an error message if not enough art are available" do
      post :create
      expect(response.status).to eq 422
      create(:art)
      post :create
      expect(response.status).to eq 422
      create(:art)
      post :create
      expect(response.status).to eq 200
    end
  end
  
  context "PUT update/:id" do
    it "assigns a new competition with the given params" do
      art = create(:art)
      challenger = create(:art)
      competition = Competition.create(art: art, challenger: challenger, user: create(:user))
      put :update, params: {id: competition.id, competition: {winner_id: challenger.id}}
      expect(response.status).to eq 200
    end
  end
end