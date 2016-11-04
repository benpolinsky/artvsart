require 'rails_helper'

RSpec.describe "Users" do
  context '/api' do
    context '/v1' do

      context 'PUT /user' do
        before do
          user = create(:user, email: "bob@foo.com", password: "batterystaple", password_confirmation: "batterystaple")
          user.confirm
          @user_token = user.auth_token
          carol = create(:user, email: "carol@foo.com")
          carol.confirm
          @carol_token = carol.auth_token
        end
        
        # hmm, should I require password... probably...
        it "can update a user's email if authenticated as matching user" do
          put '/api/v1/user', headers: {'Authorization' => @user_token}, params: {user: {email: "bob@bar.com"}}
          expect(json_response['user']['email']).to eq 'bob@bar.com'
        end
        
        it "cannot update user if not authenticated as matching user" do
          put '/api/v1/user', headers: {'Authorization' => 'correcthashbattery'}, params: {user: {email: "alice@foo.com"}}
          expect(response.code).to eq '422'
        end
        
        it "can update a user's password if authenticated with matching password" do
          put '/api/v1/user/change_password', 
          headers: {'Authorization' => @user_token}, 
          params: {
            user: {
              current_password: 'batterystaple', 
              password: 'correct horse battery staple',
              password_confirmation: 'correct horse battery staple'
            }
          }
          
          expect(json_response['user']['email']).to eq 'bob@foo.com'
          
          delete '/api/v1/users/sign_out', headers: {'Authorization' => @user_token}
          post '/api/v1/users/sign_in', params: {
            email: "bob@foo.com",
            password: "correct horse battery staple"
          }
          expect(json_response["user"]["email"]).to eq "bob@foo.com"
        end
        
        
        it "cannot update a user's password if authenticated without matching password" do
          put '/api/v1/user/change_password', 
          headers: {'Authorization' => @user_token}, 
          params: {
            user: {
              current_password: 'wrongwrongwrong', 
              password: 'correct horse battery staple',
              password_confirmation: 'correct horse battery staple'
            }
          }
        
          expect(json_response['errors']).to eq 'Your original password is incorrect.'
        end

      end
      
      context 'GET /user' do
        before do
          user = create(:user, email: "bob@foo.com", password: "batterystaple", password_confirmation: "batterystaple")
          @user_token = user.auth_token
          carol = create(:user, email: "carol@foo.com")
          @carol_token = carol.auth_token
        end
        
        it "returns a users information if authenticate as matching user" do
          get '/api/v1/user', headers: {'Authorization' => @user_token}
          expect(json_response['user']['email']).to eq 'bob@foo.com'
          expect(json_response['user']['gravatar_hash']).to_not be_blank
          expect(json_response['user']['auth_token']).to_not be_blank
          expect(json_response['user']['type']).to eq nil
        end
        
        it "doesn't return a users information if not autheticated as matching user" do
          get '/api/v1/user', headers: {'Authorization' => @carol_token}
          expect(json_response['user']['email']).to_not eq 'bob@foo.com'
        end
        
        it "doesn't retrun a users information if not authenticated at all" do
           get '/api/v1/user', headers: {'Authorization' => "IGOTYALL"}
           expect(response.code).to eq '422'
        end
      end
      
    end
  end
  
end