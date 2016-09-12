require 'rails_helper'

RSpec.describe "S3 Signing" do
  context "api" do
    context "v1" do
      it "returns a signed url" do
        get '/api/v1/s3/sign'
        expect(response.body).to eq "something"
      end
    end
  end
end