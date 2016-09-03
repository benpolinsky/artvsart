require 'rails_helper'

RSpec.describe "ArtSerializer", type: :serializer do
  it "sets an art's id and name" do
    art = create(:art, name: "My Favorite Martian", id: 1000)
    serializer = ArtSerializer.new(art)
    expect(serializer.serializable_hash[:id]).to eq 1000
    expect(serializer.serializable_hash[:name]).to eq "My Favorite Martian"
  end
end