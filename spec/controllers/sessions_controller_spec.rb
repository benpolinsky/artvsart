require 'rails_helper'

RSpec.describe SessionsController do
  describe 'POST #create' do
    before do
      @user = User.create(email: "avaliduser@me.com", password: 'password')
    end
    
    it "returns a valid user with auth token when signing in with valid credentials" do
      credentials = {
        email: @user.email,
        password: "password"
      }
      
      post :create, params: credentials
      expect(json_response["user"]["auth_token"]).to_not eq ""
      expect(json_response["user"]["email"]).to eq "avaliduser@me.com"
    end
    
    skip "does not return an auth token with invalid credentials"
    
    skip "returns errors when signing in with invalid credentials"
    
  end

end