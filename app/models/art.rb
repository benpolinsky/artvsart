# An 'Art' can either be a competitor or a challenger
# This could be used to distinguish between things like:
# 1. Higher/Lower seed
# 2. Home/Away Location
# 3. Offense/Defense
# etc...

class Art < ApplicationRecord
  
  attr_accessor :category_name
  
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  
  # when defending
  has_many :competitions
  has_many :challengers, through: :competitions

  # when challenging
  has_many :challenges, class_name: "Competition", foreign_key: "challenger_id"
  has_many :competitors, through: :challenges, source: :art
  belongs_to :category

  validates :name, presence: true
  validates :creator, presence: true
  
  enum status: [:pending_review, :published, :declined]
  delegate :number_to_percentage, to: ActiveSupport::NumberHelper
  
  serialize :additional_images, JSON

  def saves_with_category_name?(params)
    if params[:category_name].present?
      self.category = Category.find_or_create_by(name: params.delete(:category_name))
    end
    
    assign_attributes(params)
    save
  end

  def finished_competitions
    wins.or losses
  end
  
  def wins
    wins_as_competitor.or wins_as_challenger
  end
  
  def losses
    losses_as_competitor.or losses_as_challenger
  end
  
  def wins_as_competitor
    competitions.where(winner: self.id)
  end
  
  def wins_as_challenger
    challenges.where(winner: self.id)
  end
  
  def losses_as_competitor
    competitions.where(loser: self.id)
  end
  
  def losses_as_challenger
    challenges.where(loser: self.id)
  end
  
 
  def number_of_wins
    win_count.to_i
  end
  
  def number_of_losses
    loss_count.to_i
  end

  
  def win_loss_record
    "#{number_of_wins}-#{number_of_losses}"
  end
  
  def win_loss_rate
    number_of_wins.to_f/number_of_finished_competitions.to_f
  end
  
  def win_loss_percentage
    number_to_percentage(win_loss_rate*100, precision: 2)
  end

  def number_of_finished_competitions
    number_of_wins + number_of_losses
  end
  
  
  def elo_ranking
    elo_rating || Elo.config.default_rating
  end
  
  # credit where credit is due:
  # https://github.com/elovation/elovation
  def as_elo
    Elo::Player.new({
      rating: elo_ranking,
      games: finished_competitions.to_a
    })
  end

  
  def self.by_wins    
    order(win_count: :desc)
  end
  
  def self.by_losses
    order(loss_count: :desc)
  end
  
  def self.by_win_percentage
    select(
      "arts.*, COALESCE(arts.win_count::float / NULLIF((arts.win_count::float + 
      arts.loss_count::float), 0), 0) as arts_percentage"
      ).order("arts_percentage DESC")
  end
  
  def self.by_elo_ranking
    where("elo_rating IS NOT NULL").order(elo_rating: :desc)
  end
  
  def self.overall_winner
    by_wins.first
  end
  
  def self.overall_loser
    by_losses.first
  end
  
  def self.has_battled
    includes(:competitions)
  end
  
  def self.leaders(n=50)
    by_elo_ranking.limit(n)
  end
  

  
  def slug_candidates
    [
      :name,
      [:creator, :name]
    ]
  end
  
  # doing this so I can give competitions ids or records,
  # but maybe not a great idea?
  # happened when I accidentally used an instance rather than its id
  
  def to_i
    id
  end
end
