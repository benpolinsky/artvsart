class Competition < ApplicationRecord
  belongs_to :challenger, class_name: "Art"
  belongs_to :art # the competitor
  belongs_to :winner, class_name: "Art", required: false
  
  validate :winner_included?, if: Proc.new {|w| w.winner_id.present?}
  
  def winning_art
    return nil unless valid?
    winner
  end
  
  def losing_art
    return nil unless valid? && winner.present?
    winner == art ? challenger : art
  end
  
  def select_winner(new_winner_id)
    update(winner_id: new_winner_id) unless self.winner_id.present?
  end
  
  def competitor_wins!
    update(winner: art)
  end
  
  def challenger_wins!
    update(winner: challenger)
  end
  
  private

  def winner_included?
    errors.add(:winner, "Invalid Winner") unless [challenger_id, art_id].include? winner_id
  end
  
end
