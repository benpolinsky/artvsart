require 'rails_helper'
# this really isn't the best controller name.... or action name
RSpec.describe "Search Source" do
  context "v1" do
    context "GET /search_source?params" do
      context "via Artsy" do
        it "returns search results" do
          get '/api/v1/search_source', params: {source: 'Artsy', query: 'Gustav Klimt'}
          expect(json_response['results']).to_not eq nil
          expect(json_response['results'].first['title']).to match /Gustav Klimt/
          expect(json_response['results'].first['id']).to_not eq nil
        end
      
        it "returns an empty array of results if none found" do
          get '/api/v1/search_source', params: {source: 'Artsy', query: 'Benjamin David Polinsky'}
          expect(json_response['results']).to eq []
        end
      
        it "retuns a 500 error if something goes wrong" do
          allow_any_instance_of(ArtsyGateway).to receive(:search).and_raise(Faraday::Error::ResourceNotFound.new(nil))
          get '/api/v1/search_source', params: {source: 'Artsy', query: 'Benjamin David Polinsky'}
          expect(json_response['error']).to eq "Not Found"
        end
      end
      
      context "via Discogs", focus: true do
        it "returns search results" do
          get '/api/v1/search_source', params: {source: 'Discogs', query: 'Earth Rocks Harder', query_params: {search_by: 'release'}}
          expect(json_response['results']).to_not eq nil

          expect(json_response['results'].first['title']).to match /Earth Rocks Harder/
          expect(json_response['results'].first['id']).to_not eq nil
        end
      end
    end
  end
end