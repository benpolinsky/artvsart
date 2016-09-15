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

        # TODO: helper for this

        
        # add additional content eventually
        pp json_response.to_json
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
        @competition = create(:competition, art: @art, challenger: challenger)
      end
      
      it "choosing an art to win the battle returns the winning art" do
        put "/api/v1/competitions/#{@competition.id}", params: {competition: {winner_id: @art.id}}
        expect(response.code).to eq "200"

        expect(json_response["competition"]["winning_art"]["name"]).to eq "Rakim's Paid in Full"
        expect(json_response["competition"]["losing_art"]["name"]).to eq "iPhone Photo of Your Dad"
      end

      it "returns 404 if it picks a non-existent competition id" do
        put "/api/v1/competitions/#{Competition.last.id + 1}", params: {competition: {winner_id: @art.id}}
        expect(response.code).to eq "404"
      end

      it "fails if it picks a non-existent art id", focus: true do
        put "/api/v1/competitions/#{@competition.id}", params: {competition: {winner_id: 99999999}}
        
        expect(json_response["competition"]["errors"]["winner"]).to include "Invalid Winner"
      end

      it "fails if it picks an art not associated with the battle" do
        unassociated_art = create(:art, name: "Animaniacs Season 1")
        put "/api/v1/competitions/#{@competition.id}", params: {competition: {winner_id: unassociated_art.id}}
        
        expect(json_response["competition"]["errors"]["winner"]).to include "Invalid Winner"
      end
      
      skip "fails if a competition already has a winner"
    end
    
    
  end
end