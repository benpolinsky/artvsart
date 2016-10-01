require 'rails_helper'

RSpec.describe "Results" do
  context "without results" do
    skip "returns an empty results array if no competitions" do
      get '/api/v1/results'
      expect(json_response["art_results"]).to eq {}
    end
  end
  
  context "with results" do
    let(:competitor) {create(:art, name: "Art One")}
    let(:first_challenger) {create(:art, name: "Art Two")}
    let(:judge) {create(:user)}
    
    before do
      competition = competitor.competitions.create(challenger: first_challenger, user: judge)
      competition.select_winner competitor.id
      get '/api/v1/results'
    end

    it "returns the overall winner" do      
      expect(json_response["art_results"]["overall_winner"]['name']).to eq "Art One"
    end

    it "returns the overall loser" do
      expect(json_response["art_results"]["overall_loser"]['name']).to eq "Art Two"
    end
  
    it "returns the top winners" do
      expect(json_response["art_results"]["top_winners"][0]['name']).to eq "Art One"
      expect(json_response["art_results"]["top_winners"].size).to eq 1
    end
  
    it "returns the top losers" do
      expect(json_response["art_results"]["top_losers"][0]['name']).to eq "Art Two"
      expect(json_response["art_results"]["top_losers"].size).to eq 1
    end
    
    it "returns an arts win_loss_record" do
      expect(json_response["art_results"]["top_winners"][0]["win_loss_record"]).to eq "1-0"
    end
    
    it "returns an arts win_loss_rate" do
      expect(json_response["art_results"]["top_winners"][0]["win_loss_rate"]).to eq "1.0"
    end
    
    it "returns an arts win_loss_percentage" do
      expect(json_response["art_results"]["top_winners"][0]["win_loss_percentage"]).to eq "100.00%"
    end
  end
 
  
  
end