require 'rails_helper'

# An ArtImporter is the bridge between Gateways and Art in our Application:
# An ArtImporter takes a Gateway-ish object, and calls it to retrieve art info
# After the Gateway fetches and normalizes (standardizes?) data
# the Importer imports and saves the data as Art object(s).

RSpec.describe "Art Importer" do  
  it "creates an Art for Dur Kuss from its ID of 4d8b92eb4eb68a1b2c000968" do
    gateway = ArtsyGateway.new(listing_id: '4d8b92eb4eb68a1b2c000968')
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.first.name).to eq "Der Kuss (The Kiss)"
    expect(Art.first.creator).to eq "Gustav Klimt"
  end
  
  it "creates an Art for The Company of Frans Banning Cocq and Willem van Ruytenburch (The Night Watch) from its ID of 4d8b93394eb68a1b2c0010fa" do
    gateway = ArtsyGateway.new(listing_id: '4d8b93394eb68a1b2c0010fa')
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.first.name).to eq "The Company of Frans Banning Cocq and Willem van Ruytenburch (The Night Watch)"
    expect(Art.first.creator).to eq "Rembrandt Harmensz. van Rijn"
  end 
  
  it "creates Art from a list of IDs" do
    gateway = ArtsyGateway.new(listing_ids: ['4d8b92eb4eb68a1b2c000968', '4d8b93394eb68a1b2c0010fa'])
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(2)
    expect(Art.all.map(&:name)).to match_array ["Der Kuss (The Kiss)", "The Company of Frans Banning Cocq and Willem van Ruytenburch (The Night Watch)"]
    expect(Art.all.map(&:creator)).to match_array ["Gustav Klimt", "Rembrandt Harmensz. van Rijn"]
  end
  
  it "creates an Art for the album Earth Rocks Harder by the band Philadelphia Slick" do
    gateway = DiscogsGateway.new(listing_id: '7028129')
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.first.name).to eq "Earth Rocks Harder"
  end
  
  
  it "creates Art from all of Aesop Rock's albums" do
    gateway = DiscogsGateway.new(artist_id: '28104')
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}
    expect(Art.all.map(&:name)).to include "Float"
    expect(Art.all.map(&:name)).to include "Labor Days"
    expect(Art.all.map(&:name)).to include "Bazooka Tooth"
  end 
  
  it "imports movies from IMDB via OMDB" do
    usual_suspects_id = 'tt0114814'
    gateway = IMDBGateway.new(listing_id: usual_suspects_id)
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.all.first.name).to eq "The Usual Suspects"
  end
  
  it "imports art from philart" do
    art_path = "http://www.philart.net/api/art/590.json"
    gateway = PhilartGateway.new(listing_id: art_path)
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.all.first.name).to eq "Zoo Mural"
  end
  
  it "imports art from Harvard Art Gallery" do
    blacksmith_shop_id = '299985'
    gateway = HarvardArtGateway.new(listing_id: blacksmith_shop_id)
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.all.first.name).to eq "Blacksmith's Shop"
  end
  
  it "imports art from Google Books" do
    damn = 'OwM4PcKvcYMC'
    gateway = GoogleBooksGateway.new(listing_id: damn)
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.all.first.name).to eq "Damn!"
  end
  
  
  it "returns an array of imported ids on import", focus: true do
    damn = 'OwM4PcKvcYMC'
    gateway = GoogleBooksGateway.new(listing_id: damn)
    importer = ArtImporter.new(gateway)
    expect(importer.import.first).to be_a Art
  end

end