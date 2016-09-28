class BotUser < User
  def judge(competition, winner: nil)
    errors.add(:judged_competitions, "Sorry, bot.  We don't like your kind judgin' 'round 'ere!")
  end
  
  def judged_competitions
    nil
  end
end