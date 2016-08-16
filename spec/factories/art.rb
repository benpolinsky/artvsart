FactoryGirl.define do
  factory :art do
    name {Faker::Book.title}
    creator {Faker::Book.author}
  end
end