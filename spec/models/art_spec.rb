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
      art = @art
      expect(art.competitions.size).to eq 0
      expect{art.competitions.create}.to change{art.competitions.size}.by(1)
    end
       
    it "has many challengers (art) through competitions" do
      art = @art
      challenger = Art.create
      art.competitions.create(challenger: challenger)
      expect(art.challengers).to include challenger
    end
    
    it "has many challenges (inverse competitions)" do
      art = @art
      challenger = create(:art)
      expect{art.competitions.create(challenger: challenger)}.to change{challenger.challenges.count}.by(1)
    end
    
    it "has many challengers (inverse competitors)" do
      art = @art
      challenger = create(:art)
      art.competitions.create(challenger: challenger)
      expect(challenger.competitors).to include art
    end
  end
  
  context "stats" do
    before do
      @competitor = create(:art, name: "Art One")
      @first_challenger = create(:art, name: "Art Two")
      @second_challenger = create(:art, name: "Art Three")
      @third_challenger = create(:art, name: "Art Four")
    
      @competitor.competitions.create(challenger: @first_challenger, winner: 0)
      @competitor.competitions.create(challenger: @second_challenger, winner: 0)
      @competitor.competitions.create(challenger: @third_challenger, winner: 1)
      
      # ensure we test the other side of the competition
      @third_challenger.competitions.create(challenger: @competitor, winner: 1)
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
  end
  
end