require 'rails_helper'

RSpec.describe "Competitions API" do
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
  
  context '/pick_winner' do
    before do
      create(:competition)
    end
    
    it "can choose an art to win the battle" do

    end
  end
end