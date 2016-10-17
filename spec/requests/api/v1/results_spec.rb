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

  
    it "returns the top winners" do
      expect(json_response["art_results"]["top_winners"][0]['name']).to eq "Art One"
      expect(json_response["art_results"]["top_winners"].size).to eq 2
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
  
  context "limits" do
    let(:judge) {create(:user)}
    
    before do
      200.times {create(:art)}
      100.times do
        competition = Competition.stage
        competition.select_winner(competition.art.id, judge)
      end
      get '/api/v1/results'
    end 
    
    it "only returns 50 top winners" do
      expect(json_response["art_results"]["top_winners"].size).to eq 50
    end
  
  end
 
  
  
end