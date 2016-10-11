FactoryGirl.define do
  factory :user do
    email {"#{rand(100)}_#{Faker::Internet.email}"}
    password 'password'
    password_confirmation 'password'
  end
end