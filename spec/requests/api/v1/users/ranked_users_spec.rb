require 'rails_helper'

RSpec.describe "Accessing Ranked Users" do
  context "/api" do
    context "/v1" do
      context "GET /ranked_users" do
        context "50 or more" do
          before do
            visitor = create(:user)
            other_users = create_list(:user, 100)
          
            200.times {create(:art)}
            100.times do |i|
              competition = Competition.stage(other_users[i%50+1])
              competition.select_winner(competition.art.id)
            end
            User.rank!
            @headers = {'Authorization' => visitor.auth_token}
          end
        
          it "returns the top 50 users who have judged" do
            get '/api/v1/ranked_users', headers: @headers
            expect(response.code).to eq "200"
            expect(json_response['users'].size).to eq 50
            expect(json_response['users'].map{|u| u['rank']}).to match (1..50).to_a
          end         
        end
        
        context "under 50" do
          before do
            visitor = create(:user, email: "neverthat@judge.com")
            other_users = create_list(:user, 20)
          
            200.times {create(:art)}
            100.times do |i|
              competition = Competition.stage(other_users[i%10+1])
              competition.select_winner(competition.art.id)
            end
            User.rank!
            @headers = {'Authorization' => visitor.auth_token}
          end
          
          it "returns as many users who have judged" do
            get '/api/v1/ranked_users', headers: @headers
            
            expect(response.code).to eq "200"
            expect(json_response['users'].size).to eq 10
          end
          
          it "doesn't return users who have not judged" do
            get '/api/v1/ranked_users', headers: @headers
            expect(User.all.map(&:email)).to include('neverthat@judge.com')
            expect(json_response['users'].map{|user| user['email']}).to_not include('neverthat@judge.com')
          end
        end
       
        context "1" do
          before do
            visitor = create(:user, email: "neverthat@judge.com")
            other_user = create(:user, username: "ME")
          
            10.times {create(:art)}

            competition = Competition.stage(other_user)
            competition.select_winner(competition.art.id)
            
            User.rank!
            @headers = {'Authorization' => visitor.auth_token}
          end
          
          it "returns an array with 1 judges" do
            get '/api/v1/ranked_users', headers: @headers
            expect(json_response['users'].size).to eq 1
          end
          
          it "doesn't return users' emails" do
            get '/api/v1/ranked_users', headers: @headers
            expect(json_response['users'][0]['email']).to be_blank
          end
          
          it "returns users' usernames if present, and gravatar hashes" do
            get '/api/v1/ranked_users', headers: @headers
            expect(json_response['users'][0]['username']).to_not be_blank
            expect(json_response['users'][0]['gravatar_hash']).to_not be_blank
          end
        end
        context "0" do
          before do
            visitor = create(:user, email: "neverthat@judge.com")
            User.rank!
            @headers = {'Authorization' => visitor.auth_token}
          end


          it "returns an empty array with no judges" do
            get '/api/v1/ranked_users', headers: @headers
            expect(json_response['users']).to eq []
          end
        end
        
        context "deleted users" do
          before do
            judge = create(:user, email: "easycome@easygo.com", username: "imoutyo")
            visitor = create(:user)
            2.times {create(:art)}

            competition = Competition.stage(judge)
            competition.select_winner(competition.art.id)
            
            User.rank!
            judge.destroy
            @headers = {'Authorization' => visitor.auth_token}
          end
          
          it 'are not included' do
            get '/api/v1/ranked_users', headers: @headers
            expect(json_response['users'].map{|u| u['username']}).to_not include("imoutyo")
          end
        end
      end
    end
  end
end