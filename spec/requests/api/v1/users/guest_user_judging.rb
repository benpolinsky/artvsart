require 'rails_helper'

RSpec.describe "Guest Judging Competitions" do
  context "/v1" do

  
    context 'PUT /competitions/:id' do
      before do
        create_list(:art, 22)
        @user_token = GuestUser.create.auth_token
      end
      
      it "A GuestUser can only judge ten pieces of art" do
        10.times do
          competition = Competition.stage
          put "/api/v1/competitions/#{competition.id}", 
              params: {competition: {winner_id: competition.art.id}},
              headers: {'Authorization' => @user_token}          
          expect(response.code).to eq "200"
        end
        
        competition = Competition.stage
        put "/api/v1/competitions/#{competition.id}", 
            params: {competition: {winner_id: competition.art.id}},
            headers: {'Authorization' => @user_token}           

        expect(response.code).to_not eq "200"
      end
      
    end
  end
end