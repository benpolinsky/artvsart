class Competition < ApplicationRecord    
  belongs_to :user
  
  # the defender
  belongs_to :challenger, class_name: "Art"

  # the competitor
  belongs_to :art 
  belongs_to :winner, class_name: "Art", required: false
  belongs_to :loser, class_name: "Art", required: false
  
  validates :winner, presence: true, on: :update
  validates :loser, presence: true, on: :update
  validates :user, presence: true, if: Proc.new {|w| w.winner_id.present?}
    
  validate :winner_is_competitor?, if: Proc.new {|w| w.winner_id.present?}
  validate :different_competitors
  
  def winning_art
    return nil unless valid?
    winner
  end
  
  def losing_art
    return nil unless valid?
    loser
  end
  
  def select_winner(new_winner_id)
    return if winner_already_selected?
    if update(winner_id: new_winner_id, loser_id: opposite_art(new_winner_id))
      update_rankings(winner, loser)
    else
      false
    end
  end 
 
  # TODO: extract_class?  
  # clearly the next 6 methods are all dealing w/ statistics
  
  def percentage_between_arts
    self.class.percentage_between(art, challenger)
  end
  
  def winner_winning_percentage
    winner.present? ? self.class.percentage_between(winner, loser).first : nil
  end
  
  def loser_winning_percentage
    loser.present? ? self.class.percentage_between(loser, winner).first : nil
  end
  
  def challenger_winning_percentage
    self.class.percentage_between(challenger, art).first
  end
  
  def art_winning_percentage
    self.class.percentage_between(art, challenger).first
  end
  
  def art_percentages
    {
      art_winning_percentage: art_winning_percentage,
      challenger_winning_percentage: challenger_winning_percentage,
      winner_winning_percentage: winner_winning_percentage,
      loser_winning_percentage: loser_winning_percentage
    }
  end
  
  def art_name
    art.name
  end
  
  def challenger_name
    challenger.name
  end
  
  def update_rankings(winner, loser)
    assign_elo(winner, loser)
    assign_counts(winner, loser)
    winner.save
    loser.save
    
    art.reload
    challenger.reload
  end
  
  def assign_elo(winner, loser)
    winning_player = winner.as_elo
    losing_player = loser.as_elo
    
    winning_player.wins_from(losing_player)
    
    winner.assign_attributes(elo_rating: winning_player.rating)
    loser.assign_attributes(elo_rating: losing_player.rating)
  end
  
  def assign_counts(winner, loser)
    winner.assign_attributes(win_count: winner.number_of_wins+1)
    loser.assign_attributes(loss_count: loser.number_of_losses+1)
  end

  def self.calculate_elo_rankings!
    judged.all.each do |current_competition|
      winner = current_competition.winner
      loser = current_competition.loser

      current_competition.assign_elo(winner, loser)
      winner.save
      loser.save
    end
  end
  

  def self.percentage_between(art_one, art_two)
    competitions = competitions_between_competitors(art_one, art_two)
    number_of_competitons = competitions.size
    
    art_one_wins = competitions.where(winner: art_one).size
    art_two_wins = competitions.where(winner: art_two).size
    art_one_percentage = ActiveSupport::NumberHelper.number_to_percentage(art_one_wins*100.00/number_of_competitons, precision: 2)
    art_two_percentage = ActiveSupport::NumberHelper.number_to_percentage(art_two_wins*100.00/number_of_competitons, precision: 2)
    
    [art_one_percentage, art_two_percentage]
  end  
  
  def self.judged
    where('winner_id IS NOT NULL AND loser_id IS NOT NULL')
  end
  
  def self.unjudged
    where('winner_id IS NULL AND loser_id IS NULL')
  end
  
  # this bot dependency stinks
  # Art dependency meh
  def self.stage(user)
    return unless user && Art.published.count >= 2
    pair = new_battle_pair
    if user.type == "BotUser"
      user.competitions.build(art: pair[0], challenger: pair[1])
    else
      user.competitions.create(art: pair[0], challenger: pair[1])
    end
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
  
  def opposite_art(given_id)
    ids = [challenger_id, art_id]
    ids.delete(given_id.to_i)
    ids[0]
  end
  
  
  # note the same method signature with 
  # these next methods (also ::percentage_between,
  # and #opposite_art (kinda))
  
 
  def self.new_battle_pair    
    Art.all.sample(2)
  end
  
  def self.competitions_between_competitors(art_one, art_two)
    judged.where(art: art_one, challenger: art_two).or(judged.where(art: art_two, challenger: art_one))
  end
  
  def self.from_current_user(token)
    includes(:art, :challenger, :winner, :loser, :user).judged.where(users: {auth_token: token})
  end
  
 
end
