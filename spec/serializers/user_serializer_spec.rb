require 'rails_helper'

RSpec.describe "UserSerializer", type: :serializer do
  
  it "returns some basic information about the user" do
    allow(Devise).to receive(:friendly_token).and_return('mytoken')
    user = create(:user, email: "Ben@Ben.com", id: 1001)
    serializer = UserSerializer.new(user)
    expect(serializer.serializable_hash[:email]).to eq 'ben@ben.com'
    expect(serializer.serializable_hash[:type]).to eq nil # Rails STI returns base classes as nil
    expect(serializer.serializable_hash[:auth_token]).to eq 'mytoken'
  end
  
  it "returns a md5 hash for gravatar" do
    user = build(:user, email: "Ben@Ben.com", id: 1001)
    serializer = UserSerializer.new(user)
    expect(serializer.serializable_hash[:gravatar_hash]).to eq "a8eeb68641395ea82ac1c8783306548e"
  end
  
end