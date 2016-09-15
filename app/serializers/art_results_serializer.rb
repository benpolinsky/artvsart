class ArtResultsSerializer < ActiveModel::Serializer
  attributes :overall_winner, :overall_loser, :top_winners, :top_losers
  
  def overall_winner
    object.overall_winner
  end
  
  def overall_loser
    object.overall_loser
  end
  
  def top_winners
    object.by_wins
  end
  
  def top_losers
    object.by_losses
  end
  
end
