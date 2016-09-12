class CompetitionSerializer < ActiveModel::Serializer
  attributes :id, :winning_art, :losing_art
  has_one :art, serializer: ArtSerializer
  has_one :challenger, serializer: ArtSerializer
end
