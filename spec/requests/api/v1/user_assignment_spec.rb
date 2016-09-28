require 'rails_helper'

RSpec.describe "User Assignment" do
  context "Guests" do
    
    it "assigns a new guest if no token is specified" do
      allow(Devise).to receive(:friendly_token).and_return('my-auth-token')
      get '/api/v1/'
      expect(json_response["user"]).to eq ({
        "type" => "GuestUser",
        "auth_token" => "my-auth-token"
      })
    end
    
    it "retrieves the same guest if same token is set" do
      get '/api/v1/'
      guest_token = json_response["user"]["auth_token"]
      get '/api/v1/', headers: {'Authorization' => guest_token}
      expect(json_response["user"]["auth_token"]).to eq guest_token
      
    end
  end
  
  context "Users" do
    it "returns a user if a user's token is set" do
      user = create(:user, email: "mee@me.com")
      get '/api/v1/', headers: {'Authorization' => user.auth_token}
      expect(json_response["user"]["email"]).to eq "mee@me.com"
    end
  end
  
end