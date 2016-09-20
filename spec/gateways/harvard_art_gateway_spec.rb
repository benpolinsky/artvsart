require 'rails_helper'

RSpec.describe "HarvardArtGateway" do
  let(:gateway){ HarvardArtGateway.new }
  
  it "returns general search results" do
    search_results = gateway.search("Faust")
    expect(search_results.first.title).to eq "Untitled (Mr. and Mrs. Leicester Faust)"
  end
  

  it "returns results for a different search" do
    search_results = gateway.search("Oranges")
    expect(search_results.first.title).to eq "Milan photograph: Wilmarth with \"Passing Blue,\" \"Alba Sweeps,\" and \"Orange Delta for A.P.S.\" in progress at factory, 1973"
  end
  
  it "does not return results for an exact match" do
    search_results = gateway.search("Untitled (Mr. and Mrs. Leicester Faust)")
    expect(search_results.first.title).to_not eq "Untitled (Mr. and Mrs. Leicester Faust)"
    expect(search_results.first.title).to  eq "Untitled (broken pipe against white backdrop)"
  end
  
  it "returns an response with error if none found" do
    search_results = gateway.search("sssadsa32ss")
    expect(search_results[:error]).to eq "No results found!"
  end
  
  
  skip "can return all works"
  
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

  skip "returns an array of image uris for each result" do

  end

  skip "returns a name for each result" do

  end

  skip "returns a creator for each result" do

  end

  skip "returns a description for each result" do

  end

  skip "returns a release_date for each result" do
  end
end