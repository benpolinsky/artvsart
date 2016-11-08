require 'rails_helper'

RSpec.describe "User Authentication" do  
  context "signing in" do
    context "valid" do
    
      before do
        @user = User.create(email: "validuser@email.com", password: "password")
        @user.confirm
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
      
      
      it "signing in with a deleted user prompts for restoration" do
        @user = create(:user, email: "notsure@signup.com", password: 'password')
        @user.destroy
        post '/api/v1/users/sign_in', params: {email: "notsure@signup.com", password: 'password'}
        
        expect(json_response["user"]["email"]).to eq "notsure@signup.com"
        expect(json_response["message"]).to eq "Looks like you've previously signed up but deleted your account.  Re-enter your email and password below to restore it."
      end 
    end
  end
  
  context "signing out" do
    before do
      @user = User.create(email: "validuser@email.com", password: "password")
    end
    
    it "deletes auth tokens on delete" do
      delete '/api/v1/users/sign_out', headers: {'Authorization' => @user.auth_token}
      expect(response.status).to eq 200
      @user.reload
      expect(@user.auth_token).to eq ""
    end
  end
  
  context "signing up" do
    context "successfully" do
      before do
        User.delete_all

        @user_params = {
          email: "validuser@email.com",
          password: "password"
        }
      end
      
      it "returns a message waiting confirmation" do
        post '/api/v1/users', params: {user: @user_params}

        expect(json_response["notice"]).to eq "We've sent you a confirmation email.  Click the link to finish the sign up process."

        # simulate confirmation:
        # the email will send a link to the user that
        # sends them to the react app.
        # the react app then sends the confirmation code here:

        user = UnconfirmedUser.find_by(email: "validuser@email.com")

        token = user.confirmation_token

        get "/api/v1/users/confirmation?confirmation_token=#{token}"

        expect(json_response['confirmed']).to eq 'true'
        expect(json_response["user"]["auth_token"]).to_not eq ""
        expect(json_response["user"]["email"]).to eq "validuser@email.com"
      end
      
      it "tranfers existing judged competitions" do
      end
      

    end
    
    context "unsuccessfully" do
      before do
        create(:user, email: "validuser@email.com", password: 'password')
        @user_params = {
          email: "validuser@email.com",
          password: "password"
        }
      end

      it "returns an error if email taken" do
        post '/api/v1/users', params: {user: @user_params}
        expect(json_response["errors"]["email"].first).to eq "has already been taken"
      end
      
      it 'with a deleted user prompts for restoration' do
         user = create(:user, email: "notsure@signup.com", password: 'password')
         user.destroy
         post '/api/v1/users', params: {user: {email: "notsure@signup.com", password: 'password', password_confirmation: 'password'}}
         expect(json_response["user"]["email"]).to eq "notsure@signup.com"
         expect(json_response["message"]).to eq "Looks like you've previously signed up but deleted your account.  Re-enter your email and password below to restore it."
      end
      
    end
    
    context "through facebook" do
      before do
        OmniAuth.config.add_mock(:facebook, {uid: "3i47u29834", info: {email: 'ben@ben.com'}})
        Rails.application.env_config["devise.mapping"] = Devise.mappings[:user] 
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
      end
      
      it "returns the user with auth_token" do
        post '/api/v1/users/auth/facebook/callback'
        expect(json_response["user"]["auth_token"]).to_not eq ""
        expect(json_response["user"]["email"]).to eq "ben@ben.com"
      end
      
      it "returns an error if user is signed up, but without a provider" do
        create(:user, email: "ben@ben.com")
        post '/api/v1/users/auth/facebook/callback'
        expect(json_response["errors"]["email"].first).to eq "has already been taken"
      end
      
       it 'signing in with a deleted user prompts for restoration' do
         post '/api/v1/users/auth/facebook/callback'
         user = User.find_by(email: 'ben@ben.com')
         user.destroy
         post '/api/v1/users/auth/facebook/callback'
         expect(json_response["message"]).to eq "Looks like you've previously signed up but deleted your account.  Reauthorize with Facebook to restore it."
       end
    end
    
  end
  
  context "user restoration" do
    context "'normal' user" do
      before do
        User.delete_all
        @user = create(:user, email: "notsure@signup.com", password: 'password')
        @user.destroy
      end
      
      it "succeeds with valid email and password for a deleted user" do
        put '/api/v1/user/restore', params: {user: {email: "notsure@signup.com", password: 'password'}}
        expect(json_response["user"]["email"]).to eq "notsure@signup.com"
        expect(json_response["notice"]).to eq "Excellent!  You're back up and running."
      end 
      
      it "fails with invalid email" do
        put '/api/v1/user/restore', params: {user: {email: "doesntexist@signup.com", password: 'password'}}
        expect(json_response["user"]).to eq nil
        expect(json_response["errors"]).to eq "Sorry! Please check the email and password you've entered."
      end 
      
      it "fails with valid email but invalid password for a deleted user" do
        put '/api/v1/user/restore', params: {user: {email: "notsure@signup.com", password: 'amswhatiams'}}
        expect(json_response["user"]).to eq nil
        expect(json_response["errors"]).to eq "Sorry! Please check the email and password you've entered."
      end
      
      it "fails with valid email and password for a non deleted user" do
        confirmed_user = create(:user, confirmed_at: Time.zone.now, email: "confimedson@email.com", password: "password")
        put '/api/v1/user/restore', params: {user: {email: "confirmedson@email.com", password: 'password'}}
        expect(json_response["user"]).to eq nil
        expect(json_response["errors"]).to eq "Sorry! Please check the email and password you've entered."
      end
    end
    
    context "facebook-authed user", focus: true do
      before do
        OmniAuth.config.add_mock(:facebook, {uid: "3i47u29834", info: {email: 'ben@ben.com'}})
        Rails.application.env_config["devise.mapping"] = Devise.mappings[:user] 
        Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
      end
      
      it "succeeds with after reauthing from the restore point" do
        post '/api/v1/users/auth/facebook/callback'
        user = User.find_by(email: 'ben@ben.com')
        user.destroy
        post '/api/v1/users/auth/facebook/callback', params: {restoring: true}
        expect(json_response["user"]["email"]).to eq "ben@ben.com"
        expect(json_response["notice"]).to eq "Excellent!  You're back up and running."
      end 
    end
  end
  
  context "request new password" do
    before do
      @user = create(:user, email: "soontobechanged@changem.com")
    end
    
    it "successfully" do
      get '/api/v1/users/password/new', params: {user: {email: 'soontobechanged@changem.com'}}
      expect(json_response["notice"]).to eq "We've sent password instructions to that email if it was found!"
    end
  end
end