require 'rails_helper'

# An ArtImporter is the bridge between Gateways and Art in our Application:
# An ArtImporter takes a Gateway-ish object, and calls it to retrieve art infos
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
    expect(Art.all.map(&:name)).to match ["Der Kuss (The Kiss)", "The Company of Frans Banning Cocq and Willem van Ruytenburch (The Night Watch)"]
    expect(Art.all.map(&:creator)).to match ["Gustav Klimt", "Rembrandt Harmensz. van Rijn"]
  end
  
  it "creates an Art for the album Earth Rocks Harder by the band Philadelphia Slick" do
    gateway = DiscogsGateway.new(listing_id: '7028129')
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.first.name).to eq "Earth Rocks Harder"
  end
  
  skip "deals with images" do
    # we're doing this after I deal with image storage.
  end
  
  it "creates Art from all of Aesop Rock's albums" do
    # this doesn't make sense, I'd rather call a class method to search
    # and then the instance method to initialize
    
    # ids = DiscogsGateway.new.artist_works('28104').releases.map do |release|
    #   if release.main_release
    #     release.main_release
    #   else
    #     release.id
    #   end
    # end
# for the sake of rate limiting
    ids = [448748, 325759, 103307, 49169, 140859, 191915, 35984, 65772, 239762, 239766, 182327, 191908, 249184, 700163, 401280, 393410, 3233716, 579692, 678345, 759654, 3272305, 1049972, 2199591, 1122226, 1094867, 1055571, 1566833, 4378285, 5189979, 3563072, 3721230, 6424389, 5586653, 7311161, 8063994, 8499918, 8010813, 8443276, 338621, 1349570, 2444232, 4499591, 50532, 800821, 73336, 1818642, 786871, 230710, 239868, 338621]

    gateway = DiscogsGateway.new(artist_id: '28104')
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}
    expect(Art.all.map(&:name)).to include "Float"
    expect(Art.all.map(&:name)).to include "Labor Days"
    expect(Art.all.map(&:name)).to include "Bazooka Tooth"
  end 
  
  it "imports movies from IMDB via OMDB", focus: true do
    usual_suspects_id = 'tt0114814'
    gateway = IMDBGateway.new(listing_id: usual_suspects_id)
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.all.first.name).to eq "The Usual Suspects"
  end
  
  it "imports art from philart" do
    art_path = "http://www.philart.net/api/art/590.json"
    gateway = PhilartGateway.new(path: art_path)
    importer = ArtImporter.new(gateway)
    expect{importer.import}.to change{Art.count}.from(0).to(1)
    expect(Art.all.first.name).to eq "Zoo Mural"
  end
  

end