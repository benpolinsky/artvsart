require 'rails_helper'

RSpec.describe "User Types" do
  it "a user can be a User" do
    user = User.new
    expect(user.type).to eq nil # rails STI defines the base class' type as nil
  end
  
  it "a user can be a Guest" do
    guest = GuestUser.new
    expect(guest.type).to eq "GuestUser"
  end
  
  it "a user can be a Bot" do
    bot = BotUser.new
    expect(bot.type).to eq "BotUser"
  end
  
end