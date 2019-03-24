require 'rails_helper'

RSpec.describe "Art", type: :request do
  context "/v1" do
    
    context 'GET /art' do
      context "if authorized as admin" do
        before do
          @art = create(:art, name: "My Fetched Art", id: 10012)
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
      
        it "retrieves all art" do
          get '/api/v1/art', headers: @headers
        
          expect(response.code).to eq '200'
          expect(json_response['art'][0]['name']).to eq "My Fetched Art"
        end
      end
      
      context "if unauthorized" do
        it "does not allow access" do
          get '/api/v1/art'
        
          expect(response.code).to eq '422'
        end
      end
      
      context "pagination" do
        before do
          @art = create_list(:art, 100)
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
        
        it "returns pagination for art" do
          get '/api/v1/art', headers: @headers
        
          expect(response.code).to eq '200'
          expect(json_response['pages']).to_not be_blank
        end
        
        it "can return a page given in parameters" do
          get '/api/v1/art?page=2', headers: @headers
          expect(json_response['pages']['current_page']).to eq 2
          expect(json_response['pages']['last_page']).to eq true
          expect(json_response['pages']['first_page']).to eq false
          expect(json_response['pages']['next_page']).to eq nil
          expect(json_response['pages']['prev_page']).to eq 1
          expect(json_response['pages']['total_pages']).to eq 2
          expect(json_response['pages']['offset_value']).to eq 50
          expect(json_response['pages']['limit_value']).to eq 50
        end
      end
      
      context "category count", focus: true do
        before do
          music = Category.create(name: "music", color: 'blue')
          art = Category.create(name: "art", color: 'red')
          literature = Category.create(name: "literature", color: 'green')
          
          music_art = create_list(:art, 3)
          art_art = create_list(:art, 2)
          literature_art = create_list(:art, 1)
          music.arts << music_art
          music.save
          art.arts << art_art
          art.save
          literature.arts << literature_art
          literature.save
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
        
        it "returns art counts for each category" do
          get '/api/v1/art', headers: @headers
          expect(response.code).to eq '200'

          expect(json_response['category_counts'].select{|c| c['name'] == 'music'}.first['art_count']).to eq 3
          expect(json_response['category_counts'].select{|c| c['name'] == 'art'}.first['art_count']).to eq 2
          expect(json_response['category_counts'].select{|c| c['name'] == 'literature'}.first['art_count']).to eq 1

        end
        
  
      end
      
      context "searching" do
        before do
          create_list(:art, 10)
          create(:art, name: "Electric Boogalo")
          create(:art, name: "Electric City")
          create(:art, name: "City of God")
          create(:art, name: "Do The Boogalo!")
                  
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
        
        it "returns search results" do
          get '/api/v1/art?search=Boogalo', headers: @headers
          expect(json_response['art'].map {|art| art["name"]}).to match ['Electric Boogalo', 'Do The Boogalo!']
        end
        
        it "doesn't care about case" do
          get '/api/v1/art?search=boogalo', headers: @headers
          expect(json_response['art'].map {|art| art["name"]}).to match ['Electric Boogalo', 'Do The Boogalo!']
        end
      end
      
      context "searching has precedence over pagination" do
        before do
          create_list(:art, 100, name: "See you on the second page")
          create(:art, name: "Electric Boogalo")
          create(:art, name: "Electric City")
          create(:art, name: "City of God")
          create(:art, name: "Do The Boogalo!")
                  
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
        
        it "returns search results" do
          get '/api/v1/art?search=boogalo&page=1', headers: @headers
          expect(json_response['art'].map {|art| art["name"]}).to match ['Electric Boogalo', 'Do The Boogalo!']
        end
        
        it "returns no results if there aren't enough to spread to page 2" do
          get '/api/v1/art?page=2&search=Boogalo', headers: @headers
          expect(json_response['art'].map {|art| art["name"]}).to match []
        end
        
        it "returns search results from the second page if asked" do
          get '/api/v1/art?page=2&search=second+page', headers: @headers
          expect(json_response['art'].size).to eq 50
        end
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
          expect(json_response['art']['slug']).to eq 'this-album-i-made-in-my-basement'
          expect(json_response['art']['name']).to eq "This Album I Made in My Basement"
          expect(json_response['art']['creator']).to eq "Me"
          expect(json_response['art']['description']).to eq "Guys, please give this a listen.  I really think it's as good as Drake."
          expect(json_response['art']['status']).to eq "pending_review"
        end
        
        it "can be created and published at the same time" do
          @art_params[:art][:status] = 'published'
          post '/api/v1/art', params: @art_params, headers: @headers
        
          expect(response.code).to eq "200"
          expect(json_response['art']['id']).to_not be_blank
          expect(json_response['art']['slug']).to eq 'this-album-i-made-in-my-basement'
          expect(json_response['art']['name']).to eq "This Album I Made in My Basement"
          expect(json_response['art']['creator']).to eq "Me"
          expect(json_response['art']['description']).to eq "Guys, please give this a listen.  I really think it's as good as Drake."
          expect(json_response['art']['status']).to eq "published"
        end 
      end
      
      context "if not authorized" do
        it "returns 422 unauthorized" do
           post '/api/v1/art', params: @art_params
           expect(response.code).to eq "422"
        end
        
        it "returns 422 if only authorized as non-admin user" do
          normal_user = User.create(email: "nonadmin@me.com", password: 'password')
          post '/api/v1/art', params: @art_params, headers: {
            'Authorization' => normal_user.auth_token
          }
          expect(response.code).to eq "422"
        end
      end
    end
    
    context "PUT /art/:id" do
      context "if authorized as admin" do
        before do
          @art = create(:art, name: "My Fetched Art", id: 10012)
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
      
        it "updates a piece of art" do
          put '/api/v1/art/10012', params: {art: {name: "An Awesome Art"}}, headers: @headers
          expect(json_response['art']['name']).to eq "An Awesome Art"
        end
        
      
      end
      context "if unauthorized" do
        before do
          @art = create(:art, name: "My Fetched Art", id: 10012)
        end
      
        it "cannot update a piece of art" do
          put '/api/v1/art/10012', params: {art: {name: "An Awesome Art"}}
          expect(response.code).to eq '422'
        end
      end
    end
    
    context "PUT /api/v1/art/10012/update_status" do
      context "if authorized as admin" do
        before do
          @art = create(:art, name: "My Fetched Art", id: 10012)
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
      
        it "updates the status of a piece of art" do
          put '/api/v1/art/10012/update_status', params: {status: 'declined'}, headers: @headers
          expect(json_response['art']['status']).to eq 'declined'
        end
        
      
      end
      context "if unauthorized" do
        before do
          @art = create(:art, name: "My Fetched Art", id: 10012)
        end
      
        it "doesn't update the status of a piece of art" do
          put '/api/v1/art/10012/update_status', params: {status: 'declined'}
          expect(response.code).to eq '422'
        end
      end
     
    end
    
    context "PUT /api/v1/art/toggle_many" do
      context "if authorized as admin" do
        before do
          arts = create_list(:art, 10, status: 'pending_review')
          @ids = arts.map(&:id)
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
      
        it "updates the status of many pieces of art" do
          put '/api/v1/art/toggle_many', params: {status: 'published', art_ids: @ids}, headers: @headers
          expect(json_response['art'].map{|a| a['id']}).to match @ids
          expect(json_response['art'].all?{|a| a['status'] == 'published'}).to eq true
        end
        
      
      end
      skip "if unauthorized" do
        before do
          @art = create(:art, name: "My Fetched Art", id: 10012)
        end
      
        skip "doesn't update the status of a piece of art" do
          put '/api/v1/art/10012/update_status', params: {status: 'declined'}
          expect(response.code).to eq '422'
        end
      end
    end



    context "GET /art/:id" do
      before do
        @art_previous = create(:art, name: "My First Fetched Art", id: 999)
        @art = create(:art, name: "My Fetched Art", id: 10012)
        @art_last = create(:art, name: "My Last Fetched Art", id: 11999)
      end
      
      it "can fetch a piece of art" do
        get '/api/v1/art/10012'
        expect(response.code).to eq "200"
        expect(json_response['art']['id']).to eq 10012
        expect(json_response['art']['name']).to eq "My Fetched Art"
        expect(json_response['art']['slug']).to eq "my-fetched-art"
      end
      
      it "returns both the previous and next art id and name" do
        get '/api/v1/art/10012'
        expect(response.code).to eq "200"
        expect(json_response['art']['next']['id']).to eq 11999
        expect(json_response['art']['next']['name']).to eq "My Last Fetched Art"
        expect(json_response['art']['previous']['id']).to eq 999
        expect(json_response['art']['previous']['name']).to eq "My First Fetched Art"
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
        
        it "returns an array of errors if something goes wrong" do
          expect(Art.count).to eq 0
          art_params = {
            id: 'sjdvgf',
            source: "Discogs"
          }
          post '/api/v1/art/import', params: art_params, headers: @headers
          expect(json_response['errors']).to eq ["The requested resource was not found."]
          
          expect(Art.count).to eq 0
          art_params = {
            id: 'sjdvgf',
            source: "Google Books"
          }
          post '/api/v1/art/import', params: art_params, headers: @headers
          expect(json_response['errors']).to eq ["No Results Found!"]
        end
      end
    end
    
    context "DELETE /art/:id" do 
      context 'if authorized as admin' do
        before do
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
          @art = create(:art, id: 502)
        end
        
        # this isn't good... 
        it "can delete a piece of art" do
          delete "/api/v1/art/502", headers: @headers
          expect(json_response['art_deleted']).to eq true
        end
        
      end
    end
  end
end