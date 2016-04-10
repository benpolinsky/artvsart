class Art < ApplicationRecord
  
  has_many :competitions
  has_many :challengers, through: :competitions
  
  has_many :challenges, class_name: "Competition", foreign_key: "challenger_id"
  has_many :competitors, through: :challenges, source: :art
  
  #
  # has_many :followships
  # has_many :followees, through: :followships
  #
  # has_many :inverse_followships, class_name: "Followship", foreign_key: "followee_id"
  # has_many :followers, through: :inverse_followships, source: :user
  #
end
