class Competition < ApplicationRecord
  # the defender
  belongs_to :challenger, class_name: "Art"

  # the competitor
  belongs_to :art 
  belongs_to :winner, class_name: "Art", required: false
  belongs_to :loser, class_name: "Art", required: false
  
  validates :winner, presence: true, on: :update
  validates :loser, presence: true, on: :update
    
  validate :winner_is_competitor?, if: Proc.new {|w| w.winner_id.present?}
  validate :different_competitors

  def self.stage
    pair = new_battle_pair
    create(art: pair[0], challenger: pair[1]) 
  end
  
  def winning_art
    return nil unless valid?
    winner
  end
  
  def losing_art
    return nil unless valid?
    loser
  end
  
  def select_winner(new_winner_id)
    update(winner_id: new_winner_id, loser_id: opposite_art(new_winner_id)) unless winner_already_selected?
  end
  
  def competitor_wins!
    update(winner: art, loser_id: challenger.id) unless winner_already_selected?
  end
  
  def challenger_wins!
    update(winner: challenger, loser_id: art.id) unless winner_already_selected?
  end
  
  def percentage_between_arts
    self.class.percentage_between(art, challenger)
  end
  
  def self.percentage_between(art_one, art_two)
    competitions = finished_competitions.where(art: art_one, challenger: art_two).or(where(art: art_two, challenger: art_one))
    number_of_competitons = competitions.size
    
    art_one_wins = competitions.where(winner: art_one).size
    art_two_wins = competitions.where(winner: art_two).size
    art_one_percentage = ActiveSupport::NumberHelper.number_to_percentage(art_one_wins*100.00/number_of_competitons, precision: 2)
    art_two_percentage = ActiveSupport::NumberHelper.number_to_percentage(art_two_wins*100.00/number_of_competitons, precision: 2)
    
    [art_one_percentage, art_two_percentage]
  end  
  
  
  def self.finished_competitions
    where('winner_id IS NOT NULL AND loser_id IS NOT NULL')
  end
  
  private

  def winner_is_competitor?
    errors.add(:winner, "Invalid Winner") unless [challenger_id, art_id].include? winner_id
  end
  
  def different_competitors
    errors.add(:base, "Competitor and Challenger are the same!") if art == challenger
  end
  
  def winner_already_selected?
    winner_id.present?
  end
  
  def self.new_battle_pair    
    Art.all.sample(2)
  end
  
  def opposite_art(given_id)
    ids = [challenger_id, art_id]
    ids.delete(given_id)
    ids[0]
  end
  
end
