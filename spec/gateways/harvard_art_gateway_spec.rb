require 'rails_helper'

# the specs are inconsistent because they test for specific titles that aren't guaranteed
# by the search query.  

RSpec.describe "HarvardArtGateway" do
  let(:gateway){ HarvardArtGateway.new }
  

  it "returns general search results" do
    search_results = gateway.search("Faust")
    expect(search_results.first.title).to eq "Drew Gilpin Faust (b. 1947)"
  end
  

  it "returns results for a different search" do
    search_results = gateway.search("Oranges")
    expect(search_results.first.title).to_not be_blank
  end
  
  it "does return results for an exact match" do
    search_results = gateway.search("Untitled (Mr. and Mrs. Leicester Faust)")
    expect(search_results.first.title).to eq "Untitled (Mr. and Mrs. Leicester Faust)"
  end
  
  it "returns a response with error if none found" do
    search_results = gateway.search("sssadsa32ss")
    expect(search_results[:error]).to eq "No results found!"
  end
  
  it "returns a response with error if an error occurs" do
  end
  
  it "can be initialized with an id" do
    new_gateway = HarvardArtGateway.new(id: '299985')
    expect(new_gateway.items.first.title).to eq "Blacksmith's Shop"
  end
  
  it "can be initialized with an array of ids" do
    new_gateway = HarvardArtGateway.new(ids: ['299985', '304069'])
    expect(new_gateway.items.map(&:title)).to match ["Blacksmith's Shop", "Hydria (water jar) with Siren Attachment"]
  end
  
  it "finds a single listing by id" do
    expect(gateway.single_listing('299985').title).to eq "Blacksmith's Shop"
  end

  it "returns an image uri for each result" do
    search_results = gateway.search("Oranges")
    orange = search_results.first
    expect(gateway.art_image(orange)).to match /http\:\/\/nrs\.harvard\.edu/
  end

  it "returns an array of image uris for each result" do
    search_results = gateway.search("Oranges")
    orange = search_results.first
    expect(gateway.art_images(orange).all?{|img| img.match /http\:\/\/nrs\.harvard\.edu/}).to eq true
  end
  
  it "returns #additional_images as all images except the primary" do
    search_results = gateway.search("Oranges")
    orange = search_results.first
    expect(gateway.art_additional_images(orange)).to eq gateway.art_images(orange) - [gateway.art_image(orange)]
  end

  it "returns a name for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_name(listing)).to eq "Blacksmith's Shop"
  end

  it "returns a creator for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_creator(listing)).to eq "Richard Earlom, Joseph Wright of Derby, and John Boydell"
  end

  it "returns a description for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_description(listing)).to eq "Technique: Mezzotint\nPublished by John Boydell, 25 August 1771."
  end

  it "returns a release_date for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_release_date(listing)).to eq "1771"
  end
  
  it "returns a art_source_link for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_source_link(listing)).to eq "http://harvardartmuseums.org/collections/object/299985"
  end
end