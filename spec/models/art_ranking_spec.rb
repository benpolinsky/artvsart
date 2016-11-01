require 'rails_helper'

RSpec.describe "Art Ranks" do
  let(:art){create(:art)}
  context "rankings" do
    before do
      @competitor = create(:art, name: "Art One")
      @first_challenger = create(:art, name: "Art Two")
      @second_challenger = create(:art, name: "Art Three")
      @third_challenger = create(:art, name: "Art Four")
      judge = create(:user)
  
    
      competition_1 = Competition.create(user: judge, art: @competitor, challenger: @second_challenger)
      competition_1.select_winner(@competitor.id)
    
      competition_2 = Competition.create(user: judge, art: @competitor, challenger: @second_challenger)
      competition_2.select_winner(@competitor.id)
    
      competition_3 = Competition.create(user: judge, art: @competitor, challenger: @third_challenger)
      competition_3.select_winner(@third_challenger.id)
    
    
      # ensure we test the other side of the competition
      competition_4 = Competition.create(user: judge, art: @third_challenger, challenger: @competitor)
      competition_4.select_winner(@competitor.id)
    
      competition_5 = Competition.create(user: judge, art: @third_challenger, challenger: @second_challenger)
      competition_5.select_winner(@third_challenger.id)
    
      competition_6 = Competition.create(user: judge, art: @third_challenger, challenger: @second_challenger)
      competition_6.select_winner(@second_challenger.id)
    
      competition_7 = Competition.create(user: judge, art: @competitor, challenger: @second_challenger)
      competition_7.select_winner(@competitor.id)

      # @competitor = 4-1 / 80%      
      # @third_challenger = 2-2 / 50%
      # @second_challenger = 1-4 / 25%
      # @first_challenger = 0-0 / 0%
    end
    it "has a default elo ranking" do
      expect(art.elo_ranking).to_not be_nil
    end
    
    it "doesn't return the default ranking if one is set" do
      art.elo_rating = 12319
      expect(art.elo_ranking).to_not eq Elo.config.default_rating
    end
    
    
    it "#as_elo returns the art's ranking" do
      Elo.config.default_rating = 1
      expect(art.as_elo.rating).to eq 1
    end
    
    it "#as_elo returns the art's number of games" do
      expect(art.as_elo.games.size).to eq 0  
      expect(@competitor.as_elo.games.size).to eq 5
    end
    
    it "#as_elo returns if the art is a pro or not" do
      Elo.config.pro_rating_boundry = 0
      expect(@competitor.as_elo.pro_rating?).to eq true
    end
    
  end
  
  context "caluclates elo rankings" do
    it "for the winner after a new match" do
      judge = create(:user)
      Elo.config.default_rating = 1
      expect(art.elo_ranking).to eq 1
      
      challenger = create(:art, name: "Factotum by Louis Logic")
      competition = Competition.create(user: judge, art: art, challenger: challenger)
      expect{competition.select_winner(art)}.to change{art.elo_ranking}
    end
    
    it "for the loser after a new match" do
      judge = create(:user)
      Elo.config.default_rating = 1
      expect(art.elo_ranking).to eq 1
      
      challenger = create(:art, name: "Factotum by Louis Logic")
      competition = Competition.create(user: judge, art: art, challenger: challenger)
      expect{competition.select_winner(art)}.to change{challenger.elo_ranking}
    end
  end
  
  
end