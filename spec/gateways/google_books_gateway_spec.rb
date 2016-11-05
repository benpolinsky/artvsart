require 'rails_helper'


RSpec.describe "Google Books Gateway" do
  let(:gateway){GoogleBooksGateway.new}
  
  it "returns general search results" do
    search_results = gateway.search("Fahrenheit 451")
    expect(search_results.first.title).to eq "Fahrenheit 451"
  end
  
  it "returns results for a different search" do
    search_results = gateway.search("Infinite Jest")
    expect(search_results.first.title).to eq "Infinite Jest"
  end
  
  skip "returns an response with error if none found" do
    search_results = gateway.search("ssssdn29873hd38")
    expect(search_results).to eq "Book not found!"
  end
  
  it "can be initialized with an id" do
    expect(GoogleBooksGateway.new(id: '5PlBDAAAQBAJ').items.first.title).to eq "Fahrenheit 451"
  end
  
  it "can be initialized with an array of ids" do
    expect(GoogleBooksGateway.new(ids: ['5PlBDAAAQBAJ', 'Nhe2yvx6hP8C']).items.map(&:title)).to eq ["Fahrenheit 451", "Infinite Jest"]
  end

  
  it "finds a single listing by id" do
    listing = gateway.single_listing('5PlBDAAAQBAJ')
    expect(listing.title).to eq "Fahrenheit 451"
  end

  it "returns an image uri for each result" do
    search_results = gateway.search("Fahrenheit 451")
    farenheight = search_results.first
    expect(gateway.art_image(farenheight)).to match /books\/content/
  end

  it "returns an array of image uris for each result" do
    search_results = gateway.search("Fahrenheit 451")
    farenheight = search_results.first
    expect(gateway.art_images(farenheight).all?{|img| img.match /books\/content/}).to eq true
  end
  
  it "returns #additional_images as all images except the primary" do
    search_results = gateway.search("Fahrenheit 451")
    farenheight = search_results.first
    expect(gateway.art_additional_images(farenheight)).to eq gateway.art_images(farenheight) - [gateway.art_image(farenheight)]
  end

  it "returns a name for each result" do
    listing = gateway.single_listing('5PlBDAAAQBAJ')
    expect(gateway.art_name(listing)).to eq "Fahrenheit 451"
  end

  it "returns a creator for each result" do
    listing = gateway.single_listing('5PlBDAAAQBAJ')
    expect(gateway.art_creator(listing)).to eq "Ray Bradbury"
  end

  it "returns a description for each result" do
    listing = gateway.single_listing('5PlBDAAAQBAJ')
    expect(gateway.art_description(listing)).to match /post-literate future/
  end

  it "returns a release_date for each result" do
    listing = gateway.single_listing('5PlBDAAAQBAJ')
    expect(gateway.art_release_date(listing)).to eq "2016-05-30"
  end
  
  it "returns a source link for each result" do
    listing = gateway.single_listing('5PlBDAAAQBAJ')
    expect(gateway.art_source_link(listing)).to match /books.google.com/
  end


end