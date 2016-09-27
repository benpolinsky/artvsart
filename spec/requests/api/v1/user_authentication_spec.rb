require 'rails_helper'

RSpec.describe "User Authentication" do  
  context "signing in" do
    context "valid" do
    
      before do
        @user = User.create(email: "validuser@email.com", password: "password")
        post '/api/v1/users/sign_in', params: {
          email: "validuser@email.com",
          password: "password"
        }
      end

      it "returns the user with auth_token" do      
        expect(json_response["user"]["auth_token"]).to_not eq ""
        expect(json_response["user"]["email"]).to eq "validuser@email.com"
      end

    end
  
    context "not valid" do
      before do
        @user = User.create(email: "validuser@email.com", password: "password")
      end

      it "it returns an error message if an email isn't provided" do      
        post '/api/v1/users/sign_in', params: {
          email: "",
          password: "password"
        }
      
        expect(json_response["errors"]).to eq "Invalid email or password!"
      end 
    
      it "it returns an error message if an email isn't correct" do      
        post '/api/v1/users/sign_in', params: {
          email: "invaliduser@email.com",
          password: "password"
        }
      
        expect(json_response["errors"]).to eq "Invalid email or password!"
      end 
    
      it "it returns an error message if a password isn't correct" do      
        post '/api/v1/users/sign_in', params: {
          email: "validuser@email.com",
          password: "unpassword"
        }
      
        expect(json_response["errors"]).to eq "Invalid email or password!"
      end 
    end
  end
  
  context "signing out" do
    before do
      @user = User.create(email: "validuser@email.com", password: "password")
    end
    
    it "deletes auth tokens on delete" do
      delete '/api/v1/users/sign_out', params: {
        id: @user.id
      }
      expect(response.status).to eq 204
      @user.reload
      expect(@user.auth_token).to eq ""
    end
    
    
  end
  
  
end