require 'rails_helper'
# this really isn't the best controller name.... or action name
RSpec.describe "Search Source" do
  context "v1" do
    context "GET /search_source?params" do      
      context "authorized" do
      
        before do
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
        
        # not yet - artsy search isn't working as it was after 2 yrs... will
        # context "via Artsy" do
        #   it "returns search results" do
        #     get '/api/v1/search_source', params: {source: 'Artsy', query: 'Gustav Klimt'}, headers: @headers
        #     expect(json_response['results']).to_not eq nil
        #     expect(json_response['results'].first['title']).to match /Gustav Klimt/
        #     expect(json_response['results'].first['id']).to_not eq nil
        #   end
      
        #   it "returns an empty array of results if none found", focus: true do
        #     get '/api/v1/search_source', params: {source: 'Artsy', query: 'Benjamin David Polinsky'}, headers: @headers
        #     expect(json_response['errors'][0]).to eq "No Results Found!"
        #   end
        # end
      
        context "via Discogs" do
          it "returns search results" do
            get '/api/v1/search_source', params: {source: 'Discogs', query: 'Earth Rocks Harder', query_params: {search_by: 'release'}}, headers: @headers
            expect(json_response['results']).to_not eq nil

            expect(json_response['results'].first['title']).to match /Earth Rocks Harder/
            expect(json_response['results'].first['id']).to_not eq nil
          end
        end
      end
      
      context "unauthorized" do
      
        before do
          @user = User.create(email: "what@what.com", password: "password", admin: false)
          @headers = {'Authorization' => @user.auth_token}
        end
        
        it "must have an admin user present" do
          get '/api/v1/search_source', params: {source: 'Artsy', query: 'Gustav Klimt'}, headers: @headers
          expect(response.code).to eq '422'
          expect(json_response['errors']).to eq "Unauthorized!"
        end
      end
    end
  end
end