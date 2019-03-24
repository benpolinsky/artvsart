require 'rails_helper'

RSpec.describe "S3 Signing" do
  context "api" do
    context "v1" do
      context "if authorized" do
        before do
          @user = User.create(email: "what@what.com", password: "password", admin: true)
          @headers = {'Authorization' => @user.auth_token}
        end
        
        it "returns a signed url" do
          get '/api/v1/s3/sign', params: {objectName: 'mylovelypic.jpg'}, headers: @headers
          expect(json_response['signedUrl']).to match /artvsart_development/
          expect(json_response['signedUrl']).to match /mylovelypic.jpg/
        end
      end
      
      context "if unauthorized" do
        before do
          @user = User.create(email: "what@what.com", password: "password", admin: false)
          @headers = {'Authorization' => @user.auth_token}
        end
        it "returns 422 unauthorized" do
          get '/api/v1/s3/sign', params: {objectName: 'mylovelypic.jpg'}, headers: @headers
          expect(response.code).to eq '422'
        end
      end
    end
  end
end