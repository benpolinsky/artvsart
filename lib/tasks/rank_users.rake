desc "Calculate User Rankings"
task rank_users: :environment do
  User.rank!
end