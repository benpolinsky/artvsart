require 'rails_helper'


# The Various Art Gateways will plug respond to messages
# sent by an Importer.  
DISCOGS_IMAGE_ARRAY = /https\:\/\/img.discogs.com/
RSpec.describe "Discogs Gateway" do
  let(:gateway){DiscogsGateway.new}

  it "returns general search results" do
    search_results = gateway.search("Earth Rocks Harder", search_by: "Artist")
    expect(search_results.first.resource_url).to match /https\:\/\/api.discogs.com/
  end
  
  it 'returns a single listing by id' do
    erh = gateway.single_listing('7028129')
    expect(erh.title).to eq "Earth Rocks Harder"
    expect(erh.year).to eq 2015
  end
  
  it "raises an error when none are found" do
    expect{gateway.single_listing(0000000)}.to_not raise_error
  end
  
  it "returns a list of artists for a work" do
    erh = gateway.single_listing('7028129')
    expect(gateway.artist_names(erh)).to eq "Philadelphia Slick"
  end
  
  it "returns all works for an artist" do
    slick = gateway.single_listing('7028129').artists.first.id
    slick_discog = gateway.artist_works(slick)
    expect(slick_discog.pagination.items).to eq 3
    expect(slick_discog.releases.map(&:title)).to match ["Everything's Game", "Earth Rocks Harder", "Philly Sound Clash - Music To Drive By Volume 1"]
  end
  
  it "returns an image uri for each result" do
    erh = gateway.single_listing('7028129')
    expect(gateway.art_image(erh)).to match DISCOGS_IMAGE_ARRAY
  end
  
  it "returns an array of image uris for each result" do
    erh = gateway.single_listing('7028129')
    expect(gateway.art_images(erh).all?{|a| a.match(DISCOGS_IMAGE_ARRAY) }).to eq true 
  end
  
  it "returns #additional_images as all images except the primary" do
    erh = gateway.single_listing('7028129')
    expect(gateway.art_additional_images(erh)).to eq gateway.art_images(erh) - [gateway.art_image(erh)]
  end
  
  it "returns a name for each result" do
    erh = gateway.single_listing('7028129')
    expect(gateway.art_name(erh)).to eq "Earth Rocks Harder"
  end

  it "returns a creator for each result" do
    erh = gateway.single_listing('7028129')
    expect(gateway.art_creator(erh)).to eq "Philadelphia Slick"
  end
  
  it "returns a description for each result" do
    erh = gateway.single_listing('7028129')
    expect(gateway.art_description(erh)).to eq "More info at:\r\nPhillySlick.com\r\nBadTapeMusic.com\r\n\r\nIsh Quintero and Hayley Cass appear from the band Red Martina."
  end

  it "returns a release_date for each result" do
   erh = gateway.single_listing('7028129') 
   expect(gateway.art_release_date(erh)).to eq "2015-04-28"
  end
  
  it "returns a source_link" do
   erh = gateway.single_listing('7028129') 
   expect(gateway.art_source_link(erh)).to eq "https://www.discogs.com/Philadelphia-Slick-Earth-Rocks-Harder/release/7028129"
  end
  
  it "checks if it is #valid?" do
    new_gateway = DiscogsGateway.new(listing_id: 'sdfh9834')
    pp new_gateway.errors
    expect(new_gateway.valid?).to eq false
  end
  
  it "sets errors if an id is not found or invalid", focus: true do
    expect(gateway.single_listing('bogasdh083d2')).to eq false
    expect(gateway.errors).to eq ["The requested resource was not found."]
  end
  
end