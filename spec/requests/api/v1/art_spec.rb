require 'rails_helper'

RSpec.describe "Art", type: :request do
  context "/v1" do
    
    context 'GET /art' do
      it "retrieves general information" do
        get '/api/v1/art'
        
        expect(response.code).to eq '200'
        expect(json_response['total_pieces_of_art_in_catalog']).to eq 0
        expect(json_response['total_pieces_of_art_judged']).to eq 0
        expect(json_response['total_competitions']).to eq 0
      end
    end
    
    context 'POST /art' do
      before do
        @art_params = {
          art: {
            name: "This Album I Made in My Basement",
            creator: "Me",
            description: "Guys, please give this a listen.  I really think it's as good as Drake."
          }
        }
      end
      
      context "if authorized as admin" do
        
        before do
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
        
        it "can be created from some params" do
          
        
          post '/api/v1/art', params: @art_params, headers: @headers
        
          expect(response.code).to eq "200"
          expect(json_response['art']['id']).to_not be_blank
          expect(json_response['art']['name']).to eq "This Album I Made in My Basement"
          expect(json_response['art']['creator']).to eq "Me"
          expect(json_response['art']['description']).to eq "Guys, please give this a listen.  I really think it's as good as Drake."
          expect(json_response['art']['status']).to eq "pending_review"
        end
      end
      
      context "if not authorized", focus: true do
        it "returns 422 unauthorized" do
           post '/api/v1/art', params: @art_params
           expect(response.code).to eq "422"
        end
      end
    end

    context "GET /art/:id" do
      before do
        @art = create(:art, name: "My Fetched Art", id: 10012)
      end
      
      it "can fetch a piece of art" do
        get '/api/v1/art/10012'
        expect(response.code).to eq "200"
        expect(json_response['art']['id']).to eq 10012
        expect(json_response['art']['name']).to eq "My Fetched Art"
      end
    end
    
    
    context "POST /art/import" do
      context "if authorized as admin" do
        before do
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
        it "can import a piece of art" do
          expect(Art.count).to eq 0
          art_params = {
            id: '785466',
            source: "Discogs"
          }
          post '/api/v1/art/import', params: art_params, headers: @headers
          expect(json_response['result']).to eq 'imported!'
          expect(Art.count).to eq 1
        end
      end
    end
    
  end
end