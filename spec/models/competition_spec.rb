require 'rails_helper'

COMPETITION_ATTRIBUTES = [:winner]

RSpec.describe Competition, type: :model do
  COMPETITION_ATTRIBUTES.each do |attr|
    it "has a #{attr}" do
      expect(Competition.new).to respond_to attr
    end
  end
    
  it "'s winner attr determines the #winning_art and #losing_art" do
    winner = create(:art, name: "Art One")
    loser = create(:art, name: "Art Two")
    
    competition = winner.competitions.create(challenger: loser, winner: winner)
    
    expect(competition.winning_art).to eq winner
    expect(competition.losing_art).to eq loser
    
    competition.winner = loser
    
    expect(competition.winning_art).to eq loser
    expect(competition.losing_art).to eq winner
  end
  
  it "doesn't set winning or losing arts if an invalid winner is selected" do
    winner = create(:art, name: "Art One")
    loser = create(:art, name: "Art Two")
    random_winner = create(:art, name: "Art Three")
    competition = Competition.new(art: winner, challenger: loser, winner: random_winner)
    expect(competition).to_not be_valid
    expect(competition.winning_art).to be_nil
    expect(competition.losing_art).to be_nil
  end
  
  it "sets the competitor as a winner" do
    competitor = create(:art, name: "Art Competitor")
    challenger = create(:art, name: "Art Challenger")
    
    competition = competitor.competitions.create(challenger: challenger, art: competitor)
    expect{competition.competitor_wins!}.to change{competition.winner}.to(competitor)
  end
  
  it "sets the challenger" do
    competitor = create(:art, name: "Art Competitor")
    challenger = create(:art, name: "Art Challenger")
    
    competition = competitor.competitions.create(challenger: challenger)
    expect{competition.competitor_wins!}.to change{competition.winner}.to(competitor)
  end
  
  skip "competition state" do
    pending "begins as fresh"
    pending "transitions to winner_picked once a winner is picked"
  end
end