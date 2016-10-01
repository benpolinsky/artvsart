require 'rails_helper'

ART_ATTRIBUTES = [:name, :description, :creator, :created_at]
VALID_ATTRIBUTES = [:name, :creator]

RSpec.describe Art, type: :model do
  ART_ATTRIBUTES.each do |attr|
    it "has a #{attr.to_s}" do
      art = Art.new
      expect(art).to respond_to(attr)
    end
  end
  
  
  context "validations" do
    VALID_ATTRIBUTES.each do |att|
      it "is invalid without a #{att}" do
        art = build(:art, att => nil)
        expect(art).to_not be_valid
        expect(art.errors[att].size).to eq 1
        art[att] = "A Valid #{att}"
        expect(art).to be_valid
        expect(art.errors[att].size).to eq 0
      end
    end
  end
  
  context "competitions" do
    before do
      @art = create(:art)
    end
    
    it "has many competitions" do
      expect(@art.competitions.size).to eq 0
      expect{@art.competitions.create}.to change{@art.competitions.size}.by(1)
    end
       
    it "has many challengers (art) through competitions" do
      challenger = Art.create
      @art.competitions.create(challenger: challenger)
      expect(@art.challengers).to include challenger
    end
    
    it "has many challenges (inverse competitions)" do
      challenger = create(:art)
      expect{@art.competitions.create(challenger: challenger)}.to change{challenger.challenges.count}.by(1)
    end
    
    it "has many challengers (inverse competitors)" do
      challenger = create(:art)
      @art.competitions.create(challenger: challenger)
      expect(challenger.competitors).to include @art
    end
  end
  
  context "stats" do
    before do
      @competitor = create(:art, name: "Art One")
      @first_challenger = create(:art, name: "Art Two")
      @second_challenger = create(:art, name: "Art Three")
      @third_challenger = create(:art, name: "Art Four")
      judge = create(:user)
    
      
      competition_1 = Competition.create(user: judge, art: @competitor, challenger: @first_challenger)
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

      
      # third_challenger = 2-1
      # competitor = 3-1
      # second_challenger = 0-2
      # first_challenger = 0-1
    end
    
    it "display the #number_of_wins" do
      expect(@competitor.wins_as_competitor.size).to eq 2
      expect(@competitor.wins_as_challenger.size).to eq 1
      expect(@competitor.number_of_wins).to eq 3
    end
    
    it "display the #number_of_losses" do
      expect(@competitor.losses_as_competitor.size).to eq 1
      expect(@competitor.losses_as_challenger.size).to eq 0
      expect(@competitor.number_of_losses).to eq 1
    end
    
    it "displays its #win_loss_record" do
      expect(@competitor.win_loss_record).to eq "3-1"
    end
    
    it "displays its #win_loss_percentage" do
      expect(@competitor.win_loss_percentage).to eq "75.00%"
    end
    
    it "displays its #win_loss_rate" do
      expect(@competitor.win_loss_rate).to eq 0.75
    end
    
    it "orders winners by ::most_wins" do
      expect(Art.by_wins).to match [@competitor, @third_challenger]
    end
    
    it "returns the ::overall_winner" do
      expect(Art.overall_winner).to eq @competitor
    end
    
    skip "::overall_winner with ties..."
    
    it "orders losers by ::most_losses" do
      expect(Art.by_losses.size).to match ({@second_challenger.id => 2, @third_challenger.id => 1, @competitor.id => 1, @first_challenger.id => 1})
    end
    
    it "returns the overall loser" do
      expect(Art.overall_loser).to eq @second_challenger
    end
    
    
  end
  
end