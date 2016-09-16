require 'rails_helper'

RSpec.describe "HarvardArtGateway" do
  let(:gateway){ HarvardArtGateway.new }
  
  it "returns general search results" do
    search_results = gateway.search("Faust")
    expect(search_results.first.title).to eq "Untitled (Mr. and Mrs. Leicester Faust)"
  end
  

  it "returns results for a different search" do
    search_results = gateway.search("Oranges")
    expect(search_results.first.title).to eq "Chess Piece: orange pawn"
  end
  
  it "does not return results for an exact match" do
    search_results = gateway.search("Untitled (Mr. and Mrs. Leicester Faust)")
    expect(search_results.first.title).to_not eq "Untitled (Mr. and Mrs. Leicester Faust)"
    expect(search_results.first.title).to  eq "Untitled (Tupperware party, Sarasota, Florida)"
  end
  
  skip "returns an response with error if none found" do
    # search_results = gateway.search("ssss")
    # expect(search_results[:error]).to eq "Movie not found!"
  end
  
  skip "returns an array even when returning a single record" do
    # search_results = gateway.search("Sssss")
    # expect(search_results.first[:title]).to eq "Sssss"
  end

  skip "can return all works"
  
  skip "can be initialized with an id" do

  end
  
  skip "can be initialized with an array of ids" do

  end
  
  skip "finds a single listing by id" do

  end

  skip "returns an image uri for each result" do

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