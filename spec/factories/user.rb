FactoryBot.define do
  factory :user do
    email {"#{rand(100)}_#{Faker::Internet.email}"}
    password {'password'}
    password_confirmation {'password'}
  end
  
  factory :confirmed_user, class: User do
    email {"#{rand(100)}_#{Faker::Internet.email}"}
    password {'password'}
    password_confirmation {'password'}
    type {nil}
    confirmed_at {Time.zone.now}
  end
end