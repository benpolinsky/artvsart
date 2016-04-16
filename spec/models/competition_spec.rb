require 'rails_helper'

COMPETITION_ATTRIBUTES = [:winner]
RSpec.describe Competition, type: :model do
  COMPETITION_ATTRIBUTES.each do |attr|
    it "has a #{attr}" do
      expect(Competition.new).to respond_to attr
    end
  end
  
  context "validations" do
    
  end
    
  it "'s winner attr determines the #winning_art and #losing_art" do
    winner = create(:art, name: "Art One")
    loser = create(:art, name: "Art Two")
    
    competition = winner.competitions.create(challenger: loser, winner: 0)
    
    expect(competition.winning_art).to eq winner
    expect(competition.losing_art).to eq loser
    
    competition.winner = 1
    
    expect(competition.winning_art).to eq loser
    expect(competition.losing_art).to eq winner
  end
  
  it "sets the competitor as a winner" do
    competitor = create(:art, name: "Art Competitor")
    challenger = create(:art, name: "Art Challenger")
    
    competition = competitor.competitions.create(challenger: challenger)
    expect{competition.competitor_wins!}.to change{competition.winner}.to(0)
  end
  
  it "sets the challenger" do
    competitor = create(:art, name: "Art Competitor")
    challenger = create(:art, name: "Art Challenger")
    
    competition = competitor.competitions.create(challenger: challenger)
    expect{competition.competitor_wins!}.to change{competition.winner}.to(0)
  end
end