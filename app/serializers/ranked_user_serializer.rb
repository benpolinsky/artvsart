class RankedUserSerializer < ActiveModel::Serializer
  attributes :username, :gravatar_hash, :rank, :judged_competitions_count
end
