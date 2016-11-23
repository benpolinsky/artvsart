require 'rails_helper'

RSpec.describe "Competitions API" do
  context "/v1" do
    context 'CREATE /competitions' do
      before do
        create_list(:art, 2)
        post '/api/v1/competitions'
      end
  
      it "returns ok" do
        expect(response.code).to eq "200"
      end
  
      it "returns necessary attributes for a new competition" do
        HIDDEN_COMPETITION_KEYS = ["updated_at", "created_at", "winner"]

        # add additional content eventually
        expect(json_response["competition"]["id"]).to_not be_nil    
        expect(json_response["competition"]["art"]["name"]).to_not be_nil
        expect(json_response["competition"]["challenger"]["name"]).to_not be_nil
  
        HIDDEN_COMPETITION_KEYS.each do |comp_key|
          expect(json_response["competition"][comp_key]).to be_nil
        end
      end
    end
  
    context 'PUT /competitions/:id' do
      before do
        @art = create(:art, name: "Rakim's Paid in Full")
        challenger = create(:art, name: "iPhone Photo of Your Dad")
        # for now just initialize a competition from a factory with user attached
        @competition = create(:competition, art: @art, challenger: challenger) 
      end
      
      it "choosing an art to win the battle returns the winning and losing art" do
        put "/api/v1/competitions/#{@competition.id}", 
            params: {competition: {winner_id: @art.id}}
            
        expect(response.code).to eq "200"
        
        expect(json_response["competition"]["winning_art"]["name"]).
        to eq "Rakim's Paid in Full"
        
        expect(json_response["competition"]["losing_art"]["name"]).
        to eq "iPhone Photo of Your Dad"
      end
      
      it "returns the winning and losing art percentages" do
        put "/api/v1/competitions/#{@competition.id}", 
        params: {competition: {winner_id: @art.id}}
        
        expect(response.code).to eq "200"
        
        expect(json_response["competition"]["art_percentages"]["art_winning_percentage"]).
        to eq "100.00%"
        
        expect(json_response["competition"]["art_percentages"]["challenger_winning_percentage"]).
        to eq "0.00%"
      end

      it "returns 404 if it picks a non-existent competition id" do
        put "/api/v1/competitions/#{Competition.last.id + 1}", 
        params: {competition: {winner_id: @art.id}}
        
        expect(response.code).to eq "404"
      end

      it "fails if it picks a non-existent art id", focus: true do
        put "/api/v1/competitions/#{@competition.id}", 
        params: {competition: {winner_id: 99999999}}
        expect(json_response["competition"]["errors"]["winner"]).
        to include "Invalid Winner"
      end

      it "fails if it picks an art not associated with the battle" do
        unassociated_art = create(:art, name: "Animaniacs Season 1")
        put "/api/v1/competitions/#{@competition.id}", 
        params: {competition: {winner_id: unassociated_art.id}}
        
        expect(json_response["competition"]["errors"]["winner"]).to include "Invalid Winner"
      end
    end
    
    context 'GET /competitions/:id', focus: true do
      before do
        winning_art = create(:art, id: 99)
        losing_art = create(:art, id: 100)
        user = create(:user)
        
        judged_competition = create(:competition, id: 10, art: winning_art, challenger: losing_art, user: user)
        user.judge(judged_competition, winner: 99)
        
        unjudged_competition = create(:competition, id: 11, art: winning_art, challenger: losing_art)
        
      end
      
      it "can request a judged competition" do
        get "/api/v1/competitions/#{10}"

        expect(response.code).to eq "200"
        expect(json_response['competition']['winner_id']).to eq 99
        expect(json_response['competition']['loser_id']).to eq 100
      end
      
      it "cannot request an unjudged competition" do
        get "/api/v1/competitions/#{11}"
        expect(response.code).to eq "404"
      end
      
    end
    
    context "GET /competitions/master/:id" do
      skip "can request a non-judged competition and be directed to a preview/master"
    end
  end
end