require 'rails_helper'

RSpec.describe BotUser, type: :model do
  it "cannot judge competitions" do
    bot = BotUser.new
    create_list(:art, 10)
    competition = Competition.stage(bot)
    expect{bot.judge(competition, winner: competition.winner)}.to change{bot.errors.size}.from(0).to(1)    
  end
  
  
  it "does not have judged_competitions" do
    bot = BotUser.new
    create_list(:art, 10)
    expect(bot.judged_competitions).to eq nil
  end
  
  it "cannot add judged_competitions" do
    bot = BotUser.new
    create_list(:art, 10)
    competition = Competition.stage(bot)
    expect{bot.judged_competitions << competition}.to raise_error(NoMethodError)
  end

end