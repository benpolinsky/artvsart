require 'rails_helper'

RSpec.describe GuestUser, type: :model do
  before do
    create_list(:art, 30)
  end
  
  it "can only judge ten competitions before needing to register" do
    user = GuestUser.create(email: Faker::Internet.email, password: "password")
    expect(user.judged_competitions.size).to eq 0
    
    10.times.each do |time|
      competition = Competition.stage
      user.judge(competition, winner: competition.challenger_id)
    end
    
    expect(user.judged_competitions.size).to eq 10
    
    competition_over_limit = Competition.stage
    
    expect{user.judge(competition_over_limit, winner: competition_over_limit.art_id)}.
      to change{competition_over_limit.errors.size}.from(0).to(1)

    expect{user.judge(competition_over_limit, winner: competition_over_limit.art_id)}.
      to_not change{user.judged_competitions.size}
  end
  
  it "normal users can judge more than ten competitions" do
    user = User.create(email: Faker::Internet.email, password: "password")
    expect(user.judged_competitions.size).to eq 0
    
    10.times.each do |time|
      competition = Competition.stage
      user.judge(competition, winner: competition.challenger_id)
    end
    
    new_competition = Competition.stage
    
    expect{user.judge(new_competition, winner: new_competition.art_id)}.
      to change{user.judged_competitions.size}.from(10).to(11)
  end
  
  it "can #elevate_to_user, transferring competitions" do
    guest_user = GuestUser.create(email: 'guest_user@user.com', password: "password")
    guest_user.judged_competitions << create_list(:competition, 5)
    user = guest_user.elevate_to_user(email: "my_real_email", password: "my_real_password")
    expect(user.type).to eq nil # again, base class types are nil in Rails STI
  end
  
  it "does not exist after #transform to User" do
    guest_user = GuestUser.create(email: 'guest_user@user.com', password: "password")
    guest_user.judged_competitions << create_list(:competition, 5)
    user = guest_user.elevate_to_user(email: "my_real_email@email.com", password: "my_real_password")

    expect(GuestUser.find_by(email: 'my_real_email@email.com')).to eq nil
    expect(GuestUser.find_by(email: 'guest_user@user.com')).to eq nil
    
    expect(User.find_by(email: 'my_real_email@email.com').class).to eq User
  end
  
  it "assigns a guest email" do
    guest_user = GuestUser.new
    expect(guest_user.email).to match /guest_user_/
  end
  
  it "assigns a guest password" do
    guest_user = GuestUser.new
    expect(guest_user.encrypted_password).to_not be_blank
  end
  
  it "generates a token on create" do
    new_guest_user = GuestUser.create
    expect(new_guest_user.auth_token).to_not be_blank
  end
  
end