class CompetitionSerializer < ActiveModel::Serializer
  attributes :id, :winning_art, :losing_art
  belongs_to :art
  belongs_to :challenger, serializer: ArtSerializer
end
