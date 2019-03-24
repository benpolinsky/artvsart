FactoryBot.define do
  factory :art do
    name {Faker::Book.title}
    creator {Faker::Book.author}
    status {1}
  end
end