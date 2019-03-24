require 'rails_helper'

# the specs are inconsistent because they test for specific titles that aren't guaranteed
# by the search query.  
HARVARD_IMAGE_URL_REGEX = /https\:\/\/nrs\.harvard\.edu/
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
  
  it "can be initialized with an id" do
    new_gateway = HarvardArtGateway.new(listing_id: '299985')
    expect(new_gateway.items.first.title).to eq "The Blacksmith's Shop"
  end
  
  it "can be initialized with an array of ids" do
    new_gateway = HarvardArtGateway.new(listing_ids: ['299985', '304069'])
    expect(new_gateway.items.map(&:title)).to match ["The Blacksmith's Shop", "Hydria (water jar) with Siren Attachment"]
  end
  
  it "finds a single listing by id" do
    expect(gateway.single_listing('299985').title).to eq "The Blacksmith's Shop"
  end

  it "returns an image uri for each result" do
    search_results = gateway.search("Oranges")
    orange = search_results.first
    expect(gateway.art_image(orange)).to match HARVARD_IMAGE_URL_REGEX
  end

  it "returns an array of image uris for each result" do
    search_results = gateway.search("Oranges")
    orange = search_results.first
    expect(gateway.art_images(orange).all?{|img| img.match HARVARD_IMAGE_URL_REGEX}).to eq true
  end
  
  it "returns #additional_images as all images except the primary" do
    search_results = gateway.search("Oranges")
    orange = search_results.first
    expect(gateway.art_additional_images(orange)).to eq gateway.art_images(orange) - [gateway.art_image(orange)]
  end

  it "returns a name for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_name(listing)).to eq "The Blacksmith's Shop"
  end

  it "returns a creator for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_creator(listing)).to eq "Richard Earlom, Joseph Wright of Derby, and John Boydell"
  end

  it "returns a description for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_description(listing)).to eq "Technique: Mezzotint\n"
  end

  it "returns a release_date for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_release_date(listing)).to eq "August 25, 1771"
  end
  
  it "returns a art_source_link for each result" do
    listing = gateway.single_listing('299985')
    expect(gateway.art_source_link(listing)).to eq "https://www.harvardartmuseums.org/collections/object/299985"
  end
  it "checks if it is #valid?" do
    new_gateway = HarvardArtGateway.new(listing_id: 'sdfh9834')
    expect(new_gateway.valid?).to eq false
  end
  
  it "sets errors if an id is not found or invalid" do
    expect(gateway.single_listing('bogasdh083d2')).to eq false
    expect(gateway.errors).to eq ["Not Found"]
  end
  
end