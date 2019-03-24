require 'rails_helper'


RSpec.describe "IMDB Gateway" do
  # let(:gateway){IMDBGateway.new}
  
  # it "returns general search results" do
  #   search_results = gateway.search("usual suspects")
  #   expect(search_results.first[:title]).to eq "The Usual Suspects"
  # end
  
  # it "returns results for a different search" do
  #   search_results = gateway.search("Pulp")
  #   expect(search_results.first[:title]).to eq "Pulp Fiction"
  # end
  
  # it "returns an array even when OMDB returns a single record" do
  #   search_results = gateway.search("Sssss")
  #   expect(search_results.first[:title]).to eq "Sssss"
  # end
  
  # it "can be initialized with an imdb_id" do
  #   expect(IMDBGateway.new(listing_id: 'tt0114814').items.first.title).to eq "The Usual Suspects"
  # end
  
  # it "can be initialized with an array of imdb_ids" do
  #   expect(IMDBGateway.new(listing_ids: ['tt0114814', 'tt0110912']).items.map(&:title)).to match ["The Usual Suspects", "Pulp Fiction"]
  # end
  
  # it "finds a single listing by imdb_id" do
  #   expect(gateway.single_listing('tt0114814').title).to eq "The Usual Suspects"
  # end

  # it "returns an image uri for each result" do
  #   search_results = gateway.search("Pulp")
  #   pulp = search_results.first
  #   expect(pulp.image).to match /.jpg/
  # end

  # it "returns #additional_images as all images except the primary" do
  #   listing = gateway.single_listing('tt0114814')
  #   expect(gateway.art_additional_images(listing)).to eq gateway.art_images(listing) - [gateway.art_image(listing)]
  # end

  # it "returns a name for each result" do
  #   listing = gateway.single_listing('tt0114814')
  #   expect(gateway.art_name(listing)).to eq "The Usual Suspects"
  # end

  # it "returns a creator for each result" do
  #   listing = gateway.single_listing('tt0114814')
  #   expect(gateway.art_creator(listing)).to eq "Bryan Singer"
  # end

  # it "returns a description for each result" do
  #   listing = gateway.single_listing('tt0114814')
  #   expect(gateway.art_description(listing)).to eq "A sole survivor tells of the twisty events leading up to a horrific gun battle on a boat, which begin when five criminals meet at a seemingly random police lineup."
  # end

  # it "returns a release_date for each result" do
  #   listing = gateway.single_listing('tt0114814')
  #   expect(gateway.art_release_date(listing)).to eq "1995"
  # end
  
  # it "returns a source link for each result" do
  #   listing = gateway.single_listing('tt0114814')
  #   expect(gateway.art_source_link(listing)).to eq "https://www.imdb.com/title/tt0114814"
  # end
  
  # it "returns an image for each singline_listing", focus: true do
  #   listing = gateway.single_listing('tt0114814')
  #   expect(gateway.art_image(listing)).to match /.jpg/
  # end
  
  # it "returns an array of image uris for each listing", focus: true do
  #   listing = gateway.single_listing('tt0114814')
  #   expect(gateway.art_images(listing).all?{|img| img.match /.jpg/}).to eq true
  # end
  
  
  # it "checks if it is #valid?" do
  #   new_gateway = IMDBGateway.new(listing_id: 'sdfh9834')
  #   expect(new_gateway.valid?).to eq false
  # end
  
  # it "sets errors if an id is not found or invalid" do
  #   expect(gateway.single_listing('bogasdh083d2')).to eq false
  #   expect(gateway.errors).to eq ["Incorrect IMDb ID."]
  # end

end