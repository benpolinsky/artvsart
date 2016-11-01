desc "Calculate User Rankings"
task rank_users: :environment do
  User.rank!
end

task calculate_elo_rankings: :environment do
  Competition.calculate_elo_rankings!
end