class CompetitionSerializer < ActiveModel::Serializer
  # TODO: get rid of winning art and losting art and replace with ids (since they already exist...)
  attributes :id, :winning_art, :losing_art, :art_percentages, :winner_id, :loser_id
  belongs_to :art
  belongs_to :challenger, serializer: ArtSerializer
end
