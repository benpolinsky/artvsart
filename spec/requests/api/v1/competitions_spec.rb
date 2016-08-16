require 'rails_helper'

RSpec.describe "Competitions API" do
  context "/v1" do
    context '/battle' do
      before do
        create_list(:art, 2)
        get '/api/v1/battle'
      end
  
      it "returns ok" do
        expect(response.code).to eq "200"
      end
  
      it "returns necessary attributes for a new competition" do
        COMPETITION_KEYS_HIDDEN = ["updated_at", "created_at", "winner"]

        # TODO: helper
        json = JSON.parse(response.body)
        # add additional content when up to it
        expect(json["competition"]["id"]).to_not be_nil    
        expect(json["competition"]["art"]["name"]).to_not be_nil
        expect(json["competition"]["challenger"]["name"]).to_not be_nil
  
        COMPETITION_KEYS_HIDDEN.each do |comp_key|
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
        post "/api/v1/choose", competition: {id: @competition.id, winner_id: @art.id}
        json = JSON.parse(response.body)
        
        expect(json["competition"]["winning_art"]["name"]).to eq "Rakim's Paid in Full"
        expect(json["competition"]["losing_art"]["name"]).to eq "iPhone Photo of Your Dad"
      end
    
      it "returns 404 if a competition id is not specified" do
        post "/api/v1/choose", competition: {winner_id: @art.id}
        expect(response.code).to eq "404"
      end

      it "returns 404 if it picks a non-existent competition id" do
        post "/api/v1/choose", competition: {id: Competition.last.id + 1, winner_id: @art.id}
        expect(response.code).to eq "404"
      end

      it "fails if it picks a non-existent art id" do
        post "/api/v1/choose", competition: {id: @competition.id, winner_id: 99999999}
        json = JSON.parse(response.body)
        pp json
        expect(json["competition"]["errors"])
      end

      pending "fails if it picks an art not associated with the battle"
      

    end
  end
end