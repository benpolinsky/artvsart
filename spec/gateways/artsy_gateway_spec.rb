require 'rails_helper'


# The Various Art Gateways will plug respond to messages
# sent by an Importer.  

#  Not sure about Artsy, highly unstable (says on site)
#  and so many artworks aren't available...

RSpec.describe "Artsy Gateway" do
  let(:gateway){ArtsyGateway.new}
  
  it "returns general search results" do
    search_results = gateway.search("statue")
    expect(search_results.first[:type]).to eq "Artwork"
  end
  
  it "returns results for a different search" do
    search_results = gateway.search("oranges")
    expect(search_results.first[:type]).to eq "Artwork"
  end

  it "returns an image uri for each result" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_image(the_kiss)).to match /\.cloudfront.net/
  end

  it "returns an array of image uris for each result" do
    the_kiss = gateway.single_listing('4d8b92eb4eb68a1b2c000968')
    expect(gateway.art_images(the_kiss).all?{|a| a.match(/\.cloudfront.net/) }).to eq true
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

  it "returns all works" do
    warhol_collection = gateway.artist_works('andy-warhol')
    expect(warhol_collection.size).to eq 0 # i need to find an artist with collections...
  end

  # this is assuiming allworks.first will always return the earlier artwork...
  it "returns all works" do
    expect(gateway.all_works.first._attributes.title).to eq "Der Kuss (The Kiss)"
  end


end