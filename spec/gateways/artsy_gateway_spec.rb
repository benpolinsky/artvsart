require 'rails_helper'

# Works with occasional mime type errors
# Really should solve that issue

RSpec.describe "Artsy Gateway" do
  let(:old_token) {"JvTPWe4WsQO-xqX6Bts49i1QS4LS0d6TF3uhXOpx-GViySdeutQGNjljT7JhKI6d-ZEiOQMjv1Q_gzNA-uhBwVYoi2dm7BMqiSNTEjfb6lWxiDXYfR6IkkR_Nwa8BZgbmUWD7jxfurGSPbmIFEMnArfDLBPMKkXC9zqB_LrmXUK5eKEiPOUrntzPSpIzNgGdouZzCZ5M8cc5ZHCpfsbgK6K3j8jNlUN5Qsl7wRuFX_8="}
  let(:gateway) {ArtsyGateway.new}
  

  it "can renew a token" do
    AuthorizationToken.create(service: 'artsy', token: old_token)
    expect(gateway.renew_token).to_not eq old_token
  end
  
  it "can return a token" do
    expect(gateway.token).to_not be_blank
  end

  it "automatically renews a token if one is expired", focus: true do
    AuthorizationToken.create(service: 'artsy', token: old_token)
    expect{gateway.search('statue')}.to_not raise_error
  end
  
  it "returns general search results", focus: true do
    search_results = gateway.search("book")
    expect(search_results.first[:type]).to eq "artwork"
  end
  
  it "returns false and populates errors if no listing found" do
    expect(gateway.search("sssadsa32ss")).to eq false
    expect(gateway.errors).to eq ["No Results Found!"]
  end

  it "returns an image uri for each result" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_image(the_kiss["_links"]["thumbnail"]["href"])).to match /\.cloudfront.net/
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
    expect(gateway.art_additional_images(the_kiss)).to eq gateway.art_images(the_kiss) - [gateway.art_image(the_kiss["_links"]["thumbnail"]["href"])]
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

  it "returns all artist works" do
    warhol_collection = gateway.artist_works('andy-warhol')
    expect(warhol_collection.size).to eq 0 # i need to find an artist with collections...
    klimt_collection = gateway.artist_works('gustav-klimt')
    expect(klimt_collection.size).to eq 5
  end

  
  it "returns all works" do
    expect(gateway.all_works.first['title']).to eq "Der Kuss (The Kiss)"
  end
  
  # really not sure why I'd need this method...
  it "checks if it is #valid?" do
    new_gateway = ArtsyGateway.new(listing_id: 'sdfh9834')
    expect(new_gateway.valid?).to eq false
  end
  
  it "sets errors if an id is not found or invalid" do
    expect(gateway.single_listing('bogasdh083d2')).to eq false
    expect(gateway.errors).to eq ["Artwork Not Found"]
  end


end