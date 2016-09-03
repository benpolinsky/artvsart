class Competition < ApplicationRecord
  # the defender
  belongs_to :challenger, class_name: "Art"

  # the competitor
  belongs_to :art 
  belongs_to :winner, class_name: "Art", required: false
  
  validate :winner_included?, if: Proc.new {|w| w.winner_id.present?}

  def self.stage
    create(art: new_battle_pair[0], challenger: new_battle_pair[1])
  end
  
  def winning_art
    return nil unless valid?
    winner
  end
  
  def losing_art
    return nil unless valid? && winner.present?
    winner == art ? challenger : art
  end
  
  def select_winner(new_winner_id)
    update(winner_id: new_winner_id) unless winner_already_selected?
  end
  
  def competitor_wins!
    update(winner: art) unless winner_already_selected?
  end
  
  def challenger_wins!
    update(winner: challenger) unless winner_already_selected?
  end


  
  
  private

  def winner_included?
    errors.add(:winner, "Invalid Winner") unless [challenger_id, art_id].include? winner_id
  end
  
  def winner_already_selected?
    winner_id.present?
  end
  
  def self.new_battle_pair    
    Art.all.sample(2)
  end
end
