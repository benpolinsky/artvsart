require 'rails_helper'

RSpec.describe "AuthorizationToken", type: :model do

  before do
    @empty_token =  AuthorizationToken.new
    @full_token = AuthorizationToken.create(service: "artsy", token: "Ahsdhakjdniocx23", expires_on: 1.week.from_now)
  end

  
  it "can retireve Artsy's token" do
    expect(AuthorizationToken.artsy).to eq @full_token
  end
  
  it "tells if it's #expired?" do
    expect(@full_token.expired?).to eq false
    @full_token.update(expires_on: 1.week.ago)
    expect(@full_token.expired?).to eq true
  end
  
  it "is #expiring_soon? if it expires today" do
    expect(@full_token.expiring_soon?).to eq false
    @full_token.update(expires_on: 23.hours.from_now)
    expect(@full_token.expiring_soon?).to eq true
    
  end
  
end