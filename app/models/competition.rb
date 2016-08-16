class Competition < ApplicationRecord
  belongs_to :challenger, class_name: "Art"
  belongs_to :art # the competitor
  belongs_to :winner, class_name: "Art", required: false
  
  def winning_art
    winner
  end
  
  def losing_art
    art == winner ? challenger : art
  end
  
  def competitor_wins!
    update(winner: art)
  end
  
  def challenger_wins!
    update(winner: challenger)
  end
end
