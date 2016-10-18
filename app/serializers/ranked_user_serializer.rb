class RankedUserSerializer < ActiveModel::Serializer
  attributes :email, :gravatar_hash, :rank, :judged_competitions_count
end
