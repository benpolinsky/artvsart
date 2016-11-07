require 'rails_helper'

ART_ATTRIBUTES = [:name, :description, :creator, :created_at]
VALID_ART_ATTRIBUTES = [:name, :creator]

RSpec.describe Art, type: :model do
  ART_ATTRIBUTES.each do |attr|
    it "has a #{attr.to_s}" do
      art = Art.new
      expect(art).to respond_to(attr)
    end
  end
  
  context '#saves_with_category_name?' do
    before do
      @category = Category.create(name: "Film")
    end
    
    it "assigns a category by name if one that matches" do
      art = Art.new(name: "My Art", creator: "Me")
      art.saves_with_category_name?(category_name: 'Film', name: "New Art Name")
      expect(art.category).to eq @category
    end
    
    it "creates a new category if one does not exist" do
      expect(Category.find_by(name: 'Pastiche')).to eq nil
      art = Art.new(name: "My Art", creator: "Me")
      art.saves_with_category_name?(category_name: 'Pastiche', name: "New Art Name")
      expect(art.category.name).to eq 'Pastiche'
      expect(Category.find_by(name: 'Pastiche')).to_not eq nil
    end
    
    it 'updates other parameters given' do
      art = Art.new(name: "My Art", creator: "Me")
      art.saves_with_category_name?(category_name: 'Film', name: "New Art Name", creator: "You")
      expect(art.name).to eq "New Art Name"
      expect(art.creator).to eq "You"
    end
  end
  
  context "validations" do
    VALID_ART_ATTRIBUTES.each do |att|
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
  
  context "category" do
    it "belongs_to" do
      art = create(:art)
      expect{art.category = Category.create(name: 'Music')}.to change{Category.count}.by(1)
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
      @competitor = create(:art, name: "Art One", status: 1)
      @first_challenger = create(:art, name: "Art Two", status: 1)
      @second_challenger = create(:art, name: "Art Three", status: 1)
      @third_challenger = create(:art, name: "Art Four", status: 1)
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
      
      # competitor = 4-1 / 80%      
      # third_challenger = 2-2 / 50%
      # second_challenger = 1-4 / 25%
      # first_challenger = 0-0 / 0%
    end
    
    it "display the #number_of_wins" do
      expect(@competitor.wins_as_competitor.size).to eq 3
      expect(@competitor.wins_as_challenger.size).to eq 1
      expect(@competitor.number_of_wins).to eq 4
    end
    
    it "display the #number_of_losses" do
      expect(@competitor.losses_as_competitor.size).to eq 1
      expect(@competitor.losses_as_challenger.size).to eq 0
      expect(@competitor.number_of_losses).to eq 1
    end
    
    it "displays its #win_loss_record" do
      expect(@competitor.win_loss_record).to eq "4-1"
    end
    
    it "displays its #win_loss_percentage", focus: true do
      expect(@competitor.win_loss_percentage).to eq "80.00%"
    end
    
    it "displays its #win_loss_rate" do
      expect(@competitor.win_loss_rate).to eq 0.8
    end
    
    it "orders winners by ::most_wins" do
      expect(Art.by_wins).to match [@competitor, @third_challenger, @second_challenger, @first_challenger]
    end
    
    it "does not include art#pending_review in ::most_wins" do
      art_pending_review = create(:art, status: 0)
      published_art = create(:art, status: 1)
      judge = create(:user)
      
      expect(art_pending_review.status).to eq 'pending_review'
      competition = Competition.create(user: judge, art: art_pending_review, challenger: published_art)
      competition.select_winner(art_pending_review.id)
      expect(Art.by_wins).to_not include art_pending_review
    end
    
    it "returns the ::overall_winner" do
      expect(Art.overall_winner).to eq @competitor
    end
    
    it "orders losers by ::most_losses" do
      expect(Art.by_losses).to match ([@second_challenger, @third_challenger, @competitor, @first_challenger])
    end
    
    it "does not include art#pending_review in ::most_losses" do
      art_pending_review = create(:art, status: 0)
      published_art = create(:art, status: 1)
      judge = create(:user)
      
      expect(art_pending_review.status).to eq 'pending_review'
      competition = Competition.create(user: judge, art: art_pending_review, challenger: published_art)
      competition.select_winner(published_art.id)
      expect(Art.by_losses).to_not include art_pending_review
    end
    
    it "returns the overall loser" do
      expect(Art.overall_loser).to eq @second_challenger
    end
    
    it "orders by win percentage" do
      expect(Art.by_win_percentage).to match [@competitor, @third_challenger, @second_challenger, @first_challenger]
    end
    
    it "does not include art#pending_review in ::by_win_percentage" do
      art_pending_review = create(:art, status: 0)
      published_art = create(:art, status: 1)
      judge = create(:user)
      
      expect(art_pending_review.status).to eq 'pending_review'
      competition = Competition.create(user: judge, art: art_pending_review, challenger: published_art)
      competition.select_winner(art_pending_review.id)
      expect(Art.by_win_percentage).to_not include art_pending_review
    end
    
    it "returns ::leaders" do
      expect(Art.leaders).to match [@competitor, @third_challenger, @second_challenger]
    end
    
    it "only returns the top n ::leaders" do
      expect(Art.leaders(1)).to match [@competitor]
      expect(Art.leaders(0)).to match []
    end
    
    it "leaders defaults to the top 50 arts" do
      judge = create(:user)

      200.times {create(:art)}
      100.times do
        competition = Competition.stage
        competition.select_winner(competition.art.id, judge)
      end
      
      expect(Art.leaders.size).to eq 50
      expect(Art.leaders(51).size).to eq 51
    end
    
  end
  
  context "slugs" do
    let(:art){ create(:art, name: "Just here for the slugs") }
    it "attempts to use name initially" do
      expect(art.slug).to eq "just-here-for-the-slugs"
    end
  end
  
  context "Status", focus: true do
    it "begins as pending_review" do
      expect(Art.new.status).to eq "pending_review"
    end
    
    it "transitions from pending_review to published" do
      art = create(:art)
      expect{art.published!}.to change{art.status}.from('pending_review').to('published')
    end
    
    it "transitions from published to pending_review" do
      art = create(:art)
      art.published!
      expect{art.pending_review!}.to change{art.status}.from('published').to('pending_review')
    end
    
    it "transitions from published to declined" do
      art = create(:art)
      art.published!
      expect{art.declined!}.to change{art.status}.from('published').to('declined')
    end

    it "transitions from pending_review to declined" do
      art = create(:art)
      expect{art.declined!}.to change{art.status}.from('pending_review').to('declined')
    end
    
    it "Art::PendingReview" do
      art = create_list(:art, 3)
      expect(Art.pending_review.to_a).to match_array art
    end    
    
    it "Art::Published" do
      art = create_list(:art, 3, status: 1)
      expect(Art.published.to_a).to match_array art
    end
    
  
   

  end
end