class Competition < ApplicationRecord
  belongs_to :challenger, class_name: "Art"
  belongs_to :art # the competitor
  
  def winning_art
    winner == 0 ? art : challenger
  end
  
  def losing_art
    winner == 0 ? challenger : art
  end
  
  def competitor_wins!
    update(winner: 0)
  end
  
  def challenger_wins!
    update(winner: 1)
  end
end
