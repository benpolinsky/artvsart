require 'rails_helper'

RSpec.describe "Competition Serializer", type: :serializer do
  it "serializes a competition's id" do
    competition = create(:competition, id: 1001)
    
    competition.challenger.update(name: "Gang Starr's Moment of Truth")
    competition.art.update(name: "Goodnight Moon")
    
    serializer = CompetitionSerializer.new(competition)
    expect(serializer.serializable_hash[:id]).to eq 1001
    expect(serializer.serializable_hash[:art][:name]).to eq "Goodnight Moon"
    expect(serializer.serializable_hash[:challenger][:name]).to eq "Gang Starr's Moment of Truth"
  end
  
end