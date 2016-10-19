require 'rails_helper'

RSpec.describe "Philart Gateway" do
  let(:gateway){PhilartGateway.new}
  
  it "returns general search results" do
    search_results = gateway.search("zoo")
    expect(search_results.first["title"]).to eq "Zoo Mural"
  end
  
  it "returns results for a different search" do
    search_results = gateway.search("Chestnut")
    expect(search_results.first["title"]).to eq "1822 Chestnut"
  end
  
  it "returns a response with error if none found" do
    search_results = gateway.search("sssadsa32ss")
    expect(search_results[:error]).to eq "No results found!"
  end
  
  it "returns a response with error if an error occurs" do
  end
  
  it "finds a single listing by path" do
    art_path = "http://www.philart.net/api/art/590.json"
    expect(gateway.single_listing(art_path).body.title['display']).to eq "Zoo Mural"
  end
  
  it "can be initialized with the path of an art" do
    art_path = "http://www.philart.net/api/art/590.json"
    gateway = PhilartGateway.new(path: art_path)
    expect(gateway.items.first.body.title['display']).to eq "Zoo Mural"
  end
  
  it "can be initialized with an array of paths of art" do
    zoo_mural_path = "http://www.philart.net/api/art/590.json"
    fence_path = "http://www.philart.net/api/art/591.json"
    gateway = PhilartGateway.new(paths: [zoo_mural_path, fence_path])
    expect(gateway.items.map {|item| item.body.title['display']}).to match ["Zoo Mural", "Fence"]
  end
  
  it "returns a name for each result" do
    art_path = "http://www.philart.net/api/art/590.json"
    art = gateway.single_listing(art_path)
    expect(gateway.art_name(art)).to eq "Zoo Mural"
  end

  it "returns a creator for each result" do
    art_path = "http://www.philart.net/api/art/590.json"
    art = gateway.single_listing(art_path)
    expect(gateway.art_creator(art)).to eq "Geronimo Company, Paul Santoleri, and Steve Stormer"
  end
  
  it "returns 'None Listed' if no artists are present" do
    art_path = "http://www.philart.net/api/art/934.json"
    art = gateway.single_listing(art_path)
    expect(gateway.art_creator(art)).to eq "None Listed"
  end

  it "returns a description for each result" do
    art_path = "http://www.philart.net/api/art/590.json"
    art = gateway.single_listing(art_path)
    expect(gateway.art_description(art)).to eq "Focusing on the sculptural and mosaic elements.  Located: Both sides of Girard, from 34th West."
  end

  it "returns a release_date for each result" do
    art_path = "http://www.philart.net/api/art/590.json"
    art = gateway.single_listing(art_path)
    expect(gateway.art_release_date(art)).to eq '2002'
  end

  it "returns an image uri for each result" do
    art_path = "http://www.philart.net/api/art/190.json"
    art = gateway.single_listing(art_path)
    expect(gateway.art_image(art)).to match /www.philart.net\/images\/large/
  end
  
  it "returns #additional_images as all images except the primary" do
    art_path = "http://www.philart.net/api/art/190.json"
    art = gateway.single_listing(art_path)
    expect(gateway.art_additional_images(art)).to eq gateway.art_images(art) - [gateway.art_image(art)]
  end

  it "returns an array of image uris for each result"  do
    art_path = "http://www.philart.net/api/art/190.json"
    art = gateway.single_listing(art_path)
    expect(gateway.art_images(art).all?{|img| img.match /philart.net/}).to eq true
  end

  it "returns an art_source_link" do
    art_path = "http://www.philart.net/api/art/190.json"
    art = gateway.single_listing(art_path)
    expect(gateway.art_source_link(art)).to eq 'http://www.philart.net/art/The_Immigrant/190.html'
  end



end
