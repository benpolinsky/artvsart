FactoryGirl.define do
  factory :user do
    email {"#{rand(100)}_#{Faker::Internet.email}"}
    password 'password'
  end
end