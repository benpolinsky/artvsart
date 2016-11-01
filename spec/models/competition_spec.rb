require 'rails_helper'

COMPETITION_ATTRIBUTES = [:winner]

RSpec.describe Competition, type: :model do
  COMPETITION_ATTRIBUTES.each do |attr|
    it "has a #{attr}" do
      expect(Competition.new).to respond_to attr
    end
  end
  
  context "validations" do
    let(:winner) {create(:art, name: "Art One")}
    let(:loser) {create(:art, name: "Art Two")}
    let(:judge) {create(:user)}
    
    it "doesn't set winning or losing arts if an invalid winner is selected" do
      random_winner = create(:art, name: "Art Three")
      competition = Competition.new(art: winner, challenger: loser, winner: random_winner, loser: loser, user: judge)
      expect(competition).to_not be_valid
      expect(competition.winning_art).to be_nil
      expect(competition.losing_art).to be_nil
    end
  
    it "must include a winner on update" do
      competition = create(:competition, art: winner, challenger: loser)
      expect{competition.update(loser: loser)}.to change{competition.errors[:winner].size}.from(0).to(1)
    end
    
    it "must include a loser on update" do
      competition = create(:competition, art: winner, challenger: loser)
      expect{competition.update(winner: winner)}.to change{competition.errors[:loser].size}.from(0).to(1)
    end
    
    it "#winning_art only returns a winner from valid and complete competitions" do
      winner = create(:art, name: "Art Winner")
      loser = create(:art, name: "Art Loser")
    
      competition = create(:competition, art: winner, challenger: loser, winner: winner, loser: nil)
      expect(competition.valid?).to eq false
      expect(competition.winner).to eq winner
      expect(competition.winning_art).to eq nil
    end
  
    it "#losing_art only returns a loser from valid and complete competitions" do
      winner = create(:art, name: "Art Winner")
      loser = create(:art, name: "Art Loser")
    
      competition = create(:competition, art: winner, challenger: loser, loser: loser, winner: nil)
      expect(competition.valid?).to eq false
      expect(competition.loser).to eq loser
      expect(competition.losing_art).to eq nil
    end
    
    it "must be judged by a user" do
      winner = create(:art, name: "Art Winner")
      loser = create(:art, name: "Art Loser")
      
      competition = Competition.create(art: winner, challenger: loser)
      expect{competition.update(winner_id: winner.id)}.to change{competition.errors[:user].size}.from(0).to(1)
    end
  end
  
  it "can ::stage an instance of itself" do
    create_list(:art, 2)
    expect{Competition.stage}.to change {Competition.count}.from(0).to(1)
  end
  
  
  it "doesn't ::stage an instance of itself without 2 arts" do
    Art.delete_all
    expect{Competition.stage}.to_not change {Competition.count}
    create(:art)
    expect{Competition.stage}.to_not change {Competition.count}
    create(:art)
    expect{Competition.stage}.to change {Competition.count}.from(0).to(1)
  end 
  
  it "cannot be judged twice" do
    user = create(:user)
    competitor = create(:art, name: "Art Competitor")
    challenger = create(:art, name: "Art Challenger")
    competition = Competition.create(challenger: challenger, art: competitor)
    expect{competition.select_winner(challenger.id, user)}.to change{competition.winner}.from(nil).to(challenger)
    expect{competition.select_winner(competitor.id, user)}.to_not change{competition.winner}
  end
  
  it "cannot hold a battle between the same art" do
    competitor = create(:art, name: "I'm the real art.")
    expect{Competition.create(challenger: competitor, art: competitor, user: create(:user))}.to_not change{Competition.count}
  end
  
  it "increments winner and loser's respective counts after battle" do
    user = create(:user)
    competitor = create(:art, name: "Art Competitor")
    challenger = create(:art, name: "Art Challenger")
    competition = Competition.create(challenger: challenger, art: competitor)
    expect(challenger.win_count).to eq 0
    expect(competitor.loss_count).to eq 0
    competition.select_winner(challenger.id, user)
    challenger.reload
    competitor.reload
    expect(challenger.win_count).to eq 1
    expect(competitor.loss_count).to eq 1
  end
  

  
  context "statistics" do
    let(:competitor) {create(:art, name: "Art Competitor")}
    let(:challenger) {create(:art, name: "Art Challenger")}
    let(:judge) {create(:user)}
    
    it "calculates the ::percentage_between given competitors (50%/50%)" do
      arts = [competitor, challenger]
      10.times do 
        arts.reverse!
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[0], loser: arts[1], user: judge)
      end
      expect(Competition.percentage_between(competitor, challenger)).to eq ['50.00%', '50.00%']
    end
    
    it "calculates the ::percentage_between given competitors (100%/0%)" do
      arts = [competitor, challenger]
      10.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[0], loser: arts[1], user: judge)
      end
      expect(Competition.percentage_between(competitor, challenger)).to eq ['100.00%', '0.00%']
    end
    
    it "calculates the ::percentage_between given competitors (10%/90%)" do
      arts = [competitor, challenger]
      9.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[0], loser: arts[1], user: judge)
      end
      Competition.create(art: arts[0], challenger: arts[1], winner: arts[1], loser: arts[0], user: judge)
      expect(Competition.percentage_between(competitor, challenger)).to eq ['90.00%', '10.00%']
    end
    
    it "calculates the ::percentage_between given competitors (25%/75%)" do
      arts = [competitor, challenger]
      
      75.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[0], loser: arts[1], user: judge)
      end
      
      25.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[1], loser: arts[0], user: judge)
      end

      expect(Competition.percentage_between(competitor, challenger)).to eq ['75.00%', '25.00%']
    end
    
    it "calculates the ::percentage_between given competitors (39.45%/60.55%)", skip: true do
      
      # 5121 battles
      # 2020 competitor wins 
      # 3101 challenger wins
      
      arts = [competitor, challenger]
      
      2020.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[0], loser: arts[1], user: judge)
      end
      
      3101.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[1], loser: arts[0], user: judge)
      end

      expect(Competition.percentage_between(competitor, challenger)).to eq ['39.45%', '60.55%']
    end
    
    it "calculates the #percentage_between_arts of current competitors" do
      arts = [competitor, challenger]
      
      75.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[0], loser: arts[1], user: judge)
      end
      
      25.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[1], loser: arts[0], user: judge)
      end
      
      new_competiton = Competition.create(art: arts[0], challenger: arts[1], user: judge)
      expect(new_competiton.percentage_between_arts).to eq ['75.00%', '25.00%']
      
    end 
    
    it "calculates the #percentage_between_arts_for one of current competitors" do
      
      arts = [competitor, challenger]
      
      75.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[0], loser: arts[1], user: judge)
      end
      
      25.times do
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[1], loser: arts[0], user: judge)
      end
      
      new_competition = Competition.create(art: arts[0], challenger: arts[1], user: judge)
      expect(new_competition.art_winning_percentage).to eq '75.00%'
      expect(new_competition.challenger_winning_percentage).to eq '25.00%'
    end
    
    it "::calculate_elo_rankings! for all art" do
      arts = [competitor, challenger]
      10.times do 
        Competition.create(art: arts[0], challenger: arts[1], winner: arts[0], loser: arts[1], user: judge)
      end
      
      competitor.update(elo_rating: 0)
      Competition.calculate_elo_rankings!
      competitor.reload
      expect(competitor.elo_rating).to_not eq 0
    end
  end
  
  context "winners and losers", focus: true do
    let(:competitor) {create(:art, name: "Art Competitor")}
    let(:challenger) {create(:art, name: "Art Challenger")}
    let(:user) {create(:user)}
    
    it "sets the competitor as a winner" do    
      competition = competitor.competitions.create(challenger: challenger, art: competitor)
      expect{competition.select_winner(competitor.id, user)}.to change{competition.winner}.to(competitor)
    end
  
    it "sets the challenger as a loser" do    
      competition = competitor.competitions.create(challenger: challenger, art: competitor)
      expect{competition.select_winner(competitor.id, user)}.to change{competition.loser_id}.to(challenger.id)
    end
  
    it "sets the challenger as a winner" do
      competition = competitor.competitions.create(challenger: challenger)
      expect{competition.select_winner(challenger.id, user)}.to change{competition.winner}.to(challenger)
    end
  
  end
  
  skip "competition state" do
    pending "begins as fresh"
    pending "transitions to winner_picked once a winner is picked"
  end
  
  skip "assigns a uid to the @competition"
end