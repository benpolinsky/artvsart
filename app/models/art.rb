# An 'Art' can either be a competitor or a challenger
# This could be used to distinguish between things like:
# 1. Higher/Lower seed
# 2. Home/Away Location
# 3. Offense/Defense
# etc...

class Art < ApplicationRecord
  # when defending
  has_many :competitions
  has_many :challengers, through: :competitions

  # when challenging
  has_many :challenges, class_name: "Competition", foreign_key: "challenger_id"
  has_many :competitors, through: :challenges, source: :art

  validates :name, presence: true
  validates :creator, presence: true
  
  mount_uploader :image, ArtUploader

  enum status: [:pending_review, :published, :declined]

  def wins_as_competitor
    competitions.where(winner: self.id)
  end
  
  def wins_as_challenger
    challenges.where(winner: self.id)
  end
  
  def losses_as_competitor
    competitions.where.not(winner: self.id)
  end
  
  def losses_as_challenger
    challenges.where.not(winner: self.id)
  end
  
  def wins
    wins_as_competitor + wins_as_challenger
  end
  
  def losses
    losses_as_competitor + losses_as_challenger
  end
  
  def number_of_wins
    wins.size
  end
  
  def number_of_losses
    losses.size
  end
end
