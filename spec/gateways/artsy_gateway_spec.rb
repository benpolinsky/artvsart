require 'rails_helper'


# The Various Art Gateways will plug respond to messages
# sent by an Importer.  

#  Not sure about Artsy, highly unstable (says on site)
#  and so many artworks aren't available...

RSpec.describe "Artsy Gateway", :vcr do
  let(:old_token) {"JvTPWe4WsQO-xqX6Bts49i1QS4LS0d6TF3uhXOpx-GViySdeutQGNjljT7JhKI6d-ZEiOQMjv1Q_gzNA-uhBwVYoi2dm7BMqiSNTEjfb6lWxiDXYfR6IkkR_Nwa8BZgbmUWD7jxfurGSPbmIFEMnArfDLBPMKkXC9zqB_LrmXUK5eKEiPOUrntzPSpIzNgGdouZzCZ5M8cc5ZHCpfsbgK6K3j8jNlUN5Qsl7wRuFX_8="}
  let(:gateway) {ArtsyGateway.new}
  before do
    AuthorizationToken.create(service: 'artsy', token: old_token)
  end

  it "can renew a token" do
    expect(gateway.renew_token).to_not eq old_token
  end
  
  it "can return a token" do
    expect(gateway.token).to_not be_blank
  end

  # so, this isn't testing the case at all and is useless as is
  pending "automatically renews a token if one is expired"
  
  it "returns general search results" do
    search_results = gateway.search("statue")
    expect(search_results.first[:type]).to eq "Artwork"
  end
  
  it "returns false and populates errors if no listing found" do
    expect(gateway.search("sssadsa32ss")).to eq false
    expect(gateway.errors).to eq ["No Results Found!"]
  end

  it "returns an image uri for each result" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_image(the_kiss)).to match /\.cloudfront.net/
  end

  it "returns an array of image uris for each result" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_images(the_kiss).all?{|a| a.match(/\.cloudfront.net/) }).to eq true
  end
  
  it "returns a source link for each result" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_source_link(the_kiss)).to eq "http://www.artsy.net/artwork/gustav-klimt-der-kuss-the-kiss"
  end
  
  it "returns #additional_images as all images except the primary" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_additional_images(the_kiss)).to eq gateway.art_images(the_kiss) - [gateway.art_image(the_kiss)]
  end

  it "returns a name for each result" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_name(the_kiss)).to eq "Der Kuss (The Kiss)"
  end

  it "returns a creator for each result" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_creator(the_kiss)).to eq "Gustav Klimt"
  end

  it "returns a description for each result" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_description(the_kiss)).to eq ""
  end

  it "returns a release_date for each result" do
   the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
   expect(gateway.art_release_date(the_kiss)).to eq "1907-1908"
  end
  
  it "checks if it is #valid?" do
    new_gateway = ArtsyGateway.new(listing_id: 'sdfh9834')
    expect(new_gateway.valid?).to eq false
  end
  
  it "sets errors if an id is not found or invalid" do
    expect(gateway.single_listing('bogasdh083d2')).to eq false
    expect(gateway.errors).to eq ["No Results Found!"]
  end


end