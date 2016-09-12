require 'rails_helper'

RSpec.describe "S3Signer" do
  it "takes an object name and returns a put url" do
    signer = S3Signer.new('mylovelyobject.jpg');
    expect(signer.put_url).to match /artvsart-development/
    expect(signer.put_url).to match /mylovelyobject.jpg/
  end
end