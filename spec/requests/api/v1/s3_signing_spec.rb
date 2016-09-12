require 'rails_helper'

RSpec.describe "S3 Signing" do
  context "api" do
    context "v1" do
      it "returns a signed url" do
        get '/api/v1/s3/sign', params: {objectName: 'mylovelypic.jpg'}
        expect(json_response['signedUrl']).to match /artvsart-development/
        expect(json_response['signedUrl']).to match /mylovelypic.jpg/
      end
    end
  end
end