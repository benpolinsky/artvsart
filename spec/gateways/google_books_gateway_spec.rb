require 'rails_helper'


RSpec.describe "Google Books Gateway" do
  
  let(:gateway){GoogleBooksGateway.new}
  
  it "returns general search results" do
    search_results = gateway.search("Fahrenheit 451")
    expect(search_results.first[:title]).to eq "Fahrenheit 451"
  end
  
  it "returns results for a different search" do
    search_results = gateway.search("Infinite Jest")
    expect(search_results.first[:title]).to eq "Infinite Jest"
  end
  
  it "can be initialized with an id" do
    result = GoogleBooksGateway.new(listing_id: 'AU9YtwAACAAJ')
    expect(result.items.first.title).to eq "Fahrenheit 451"
  end
  
  it "can be initialized with an array of ids" do
    expect(GoogleBooksGateway.new(listing_ids: ['AU9YtwAACAAJ', 'Nhe2yvx6hP8C']).items.map(&:title)).to eq ["Fahrenheit 451", "Infinite Jest"]
  end

  
  it "finds a single listing by id" do
    listing = gateway.single_listing('AU9YtwAACAAJ')
    expect(listing.title).to eq "Fahrenheit 451"
  end

  it "returns an image uri for each result" do
    farenheight = gateway.single_listing('AU9YtwAACAAJ')
    expect(gateway.art_image(farenheight)).to match /books\/content/
  end

  it "returns an array of image uris for each result" do
    farenheight = gateway.single_listing('AU9YtwAACAAJ')
    expect(gateway.art_images(farenheight).all?{|img| img.match /books\/content/}).to eq true
  end
  
  it "returns #additional_images as all images except the primary" do
    farenheight = gateway.single_listing('AU9YtwAACAAJ')
    expect(gateway.art_additional_images(farenheight)).to eq gateway.art_images(farenheight) - [gateway.art_image(farenheight)]
  end

  it "returns a name for each result" do
    listing = gateway.single_listing('AU9YtwAACAAJ')
    expect(gateway.art_name(listing)).to eq "Fahrenheit 451"
  end

  it "returns a creator for each result" do
    listing = gateway.single_listing('AU9YtwAACAAJ')
    expect(gateway.art_creator(listing)).to eq "Ray Bradbury"
  end

  it "returns a description for each result" do
    listing = gateway.single_listing('AU9YtwAACAAJ')
    expect(gateway.art_description(listing)).to match /a work of even greater impact/
  end

  it "returns a release_date for each result" do
    listing = gateway.single_listing('AU9YtwAACAAJ')
    expect(gateway.art_release_date(listing)).to eq "1993"
  end
  
  it "returns a source link for each result" do
    listing = gateway.single_listing('AU9YtwAACAAJ')
    expect(gateway.art_source_link(listing)).to match /books.google.com/
  end

  
  it "checks if it is #valid?" do
    new_gateway = GoogleBooksGateway.new(listing_id: 'sdfh9834')
    expect(new_gateway.valid?).to eq false
  end
  
  it "sets errors if an id is not found or invalid" do
    expect(gateway.single_listing('bogasdh083d2')).to eq false
    expect(gateway.errors).to eq ["notFound: The volume ID could not be found."]
  end

end