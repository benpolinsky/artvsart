require 'rails_helper'

RSpec.describe "Categories" do
  context "unauthorized" do
    it "doesn't grant access" do
      get '/api/v1/categories'
      expect(response.code).to eq "422"
    end
  end
  
  context "authorized" do
    before do
      @user = User.create(email: "what@what.com", password: "password", admin: true)
      @headers = {'Authorization' => @user.auth_token}
       Category.create([{id: 1, name: "Music"}, {id: 2, name: "Art"}, {id: 3, name: "Film"}])
    end   

    context "GET /categories" do   
      it "returns all categories" do
        get '/api/v1/categories', headers: @headers
        
        expect(response.code).to eq "200"
        expect(json_response['categories']).to match [
          {'id' => 1, 'name' => "Music", "color" => nil, "slug" => "music", 'parent_category' => nil, "parent_id" => nil},
          {'id' => 2, 'name' => "Art", "color" => nil, "slug" => "art", 'parent_category' => nil, "parent_id" => nil},
          {'id' => 3, 'name' => "Film", "color" => nil, "slug" => "film", 'parent_category' => nil, "parent_id" => nil}
        ]
        
      end
    end
    
    context "GET /categories/:id" do
      it "returns one category" do
        get '/api/v1/categories/1', headers: @headers
        
        expect(response.code).to eq "200"
        expect(json_response['category']).to match(
          {'id' => 1, 'name' => "Music", "color" => nil, "slug" => "music", 'parent_category' => nil, "parent_id" => nil}
        )
        
      end
    end
    
    context "PUT /categories/:id" do
      it "updates a category" do
        put '/api/v1/categories/1', 
        params: {category: {name: "Musical Works", color: "Blue"}}, 
        headers: @headers
        
        expect(response.code).to eq "200"
        expect(json_response['category']).to match(
          {'id' => 1, 'name' => "Musical Works", "color" => "Blue", "slug" => "music", 'parent_category' => nil, "parent_id" => nil}
        )
      end
      
      context "POST /categories" do
        it "creates a category" do
          post '/api/v1/categories', 
          params: {category: {name: "Statues", color: "Green"}}, 
          headers: @headers
        
          expect(response.code).to eq "200"
          expect(json_response['category']['name']).to eq "Statues"
          expect(json_response['category']['slug']).to eq "statues"
          expect(json_response['category']['color']).to eq "Green"
        end
        
        it "doesn't create a category if no name is specified" do
          post '/api/v1/categories', 
          params: {category: {name: "", color: "Green"}}, 
          headers: @headers

          expect(json_response['errors']['name'][0]).to eq "can't be blank"
        end
      end
      
    end
  end
end