require 'rails_helper'

RSpec.describe "Art", type: :request do
  context "/v1" do
    
    context 'POST /art' do
      it "can be created from some params" do
        art_params = {
          art: {
            name: "This Album I Made in My Basement",
            creator: "Me",
            description: "Guys, please give this a listen.  I really think it's as good as Drake."
          }
        }
        post '/api/v1/art', params: art_params
        
        expect(response.code).to eq "200"
        expect(json_response['art']['id']).to_not be_blank
        expect(json_response['art']['name']).to eq "This Album I Made in My Basement"
        expect(json_response['art']['creator']).to eq "Me"
        expect(json_response['art']['description']).to eq "Guys, please give this a listen.  I really think it's as good as Drake."
        expect(json_response['art']['status']).to eq "pending_review"
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
      
      it "returns a 404 if no art is found" do
      end
    end
    
    
  end
end