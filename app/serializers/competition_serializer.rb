class CompetitionSerializer < ActiveModel::Serializer
  attributes :id, :art, :challenger, :winning_art, :losing_art
end
