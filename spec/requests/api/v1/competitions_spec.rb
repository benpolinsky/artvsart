require 'rails_helper'

RSpec.describe "Competitions API" do
  context "/v1" do
    context '/battle' do
      before do
        create_list(:art, 2)
        post '/api/v1/battle'
      end
  
      it "returns ok" do
        expect(response.code).to eq "200"
      end
  
      it "returns necessary attributes for a new competition" do
        HIDDEN_COMPETITION_KEYS = ["updated_at", "created_at", "winner"]

        # TODO: helper
        json = JSON.parse(response.body)
        # add additional content when up to it
        expect(json["competition"]["id"]).to_not be_nil    
        expect(json["competition"]["art"]["name"]).to_not be_nil
        expect(json["competition"]["challenger"]["name"]).to_not be_nil
  
        HIDDEN_COMPETITION_KEYS.each do |comp_key|
          expect(json["competition"][comp_key]).to be_nil
        end
      end
    end
  
    context '/choose' do
      before do
        @art = create(:art, name: "Rakim's Paid in Full")
        challenger = create(:art, name: "iPhone Photo of Your Dad")
        @competition = create(:competition, art: @art, challenger: challenger)
      end
      
      it "choosing an art to win the battle returns the winning art" do
        put "/api/v1/choose", params: {competition: {id: @competition.id, winner_id: @art.id}}
        json = JSON.parse(response.body)
        
        expect(json["competition"]["winning_art"]["name"]).to eq "Rakim's Paid in Full"
        expect(json["competition"]["losing_art"]["name"]).to eq "iPhone Photo of Your Dad"
      end
    
      it "returns 404 if a competition id is not specified" do
        put "/api/v1/choose", params: {competition: {winner_id: @art.id}}
        expect(response.code).to eq "404"
      end

      it "returns 404 if it picks a non-existent competition id" do
        put "/api/v1/choose", params: {competition: {id: Competition.last.id + 1, winner_id: @art.id}}
        expect(response.code).to eq "404"
      end

      it "fails if it picks a non-existent art id", focus: true do
        put "/api/v1/choose", params: {competition: {id: @competition.id, winner_id: 99999999}}
        json = JSON.parse(response.body)
        expect(json["competition"]["errors"]["winner"]).to include "Invalid Winner"
      end

      it "fails if it picks an art not associated with the battle" do
        unassociated_art = create(:art, name: "Animaniacs Season 1")
        put "/api/v1/choose", params: {competition: {id: @competition.id, winner_id: unassociated_art.id}}
        json = JSON.parse(response.body)
        expect(json["competition"]["errors"]["winner"]).to include "Invalid Winner"
      end
    end
    
    
  end
end