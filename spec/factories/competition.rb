FactoryGirl.define do
  factory :competition do
    art 
    association :challenger, factory: :art
  end
end