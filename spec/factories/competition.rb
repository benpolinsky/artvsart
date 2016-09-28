FactoryGirl.define do
  factory :competition do
    art 
    association :challenger, factory: :art
  end
  
  factory :judged_competitions, parent: :competition do
    after(:create) do |competition|
      competition.winner = competition.art
      competition.loser = competition.challenger
      competition.save
    end
  end
end