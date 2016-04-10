require 'rails_helper'

ART_ATTRIBUTES = [:name, :description, :creator, :created_at]
RSpec.describe Art, type: :model do
  ART_ATTRIBUTES.each do |attr|
    it "has a #{attr.to_s}" do
      art = Art.new
      expect(art).to respond_to(attr)
    end
  end
  
  
  context "validations" do
  end
  
  context "competitions" do
    it "has many competitions" do
      art = Art.create
      expect(art.competitions.size).to eq 0
      expect{art.competitions.create}.to change{art.competitions.size}.by(1)
    end
       
    it "has many challengers (art) through competitions" do
      art = Art.create
      challenger = Art.create
      art.competitions.create(challenger: challenger)
      expect(art.challengers).to include challenger
    end
    
    it "has many challenges (inverse competitions)" do
      art = Art.create
      challenger = Art.create
      expect{art.competitions.create(challenger: challenger)}.to change{challenger.challenges.count}.by(1)
    end
    
    it "has many challengers (inverse competitors)" do
      art = Art.create
      challenger = Art.create
      art.competitions.create(challenger: challenger)
      expect(challenger.competitors).to include art
    end
  end
  
end