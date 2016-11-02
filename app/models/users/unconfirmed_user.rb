# If we look at the User Inheritance...
# What's changing... well, one thing is
# limit of competitions they can judge...

# Guest users have some inital values

# User.  Competition Limit: unliminted. Inital Values -> From db (handled by Rails)
# GuestUser.  Competition Limit: 10, InitalValues -> come from time.zone.now.
# UnconfirmedUser.  Competiton Limit 20: initialvalues -> come from user/db

# Composition / Injection:
# Judgeability.new(competition_limit: 10, error_value: "Please Sign Up to Continue Judging")
# Judgeability.new(competition_limit: 20, error_value: "Please Confirm Your Email Continue Judging")
# default: Judging.new(competition_limit: nil, error_value: nil)

# Then provide default attributes for a GuestUser on inital rather than having it in the class.
# Then you can get rid of inheritance.

class UnconfirmedUser < User
  def judge(competition, winner: nil)
    if judged_competitions.size < 20
      super(competition, winner: winner)
    else
      competition.errors.add(:base, 'Please Confirm Your Email to Continue Judging')
      competition
    end
  end
end