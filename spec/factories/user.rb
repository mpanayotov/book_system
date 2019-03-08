FactoryBot.define do
  factory :user do
    name { Faker::Name.name }

    trait :with_upvotes do
      after(:create) do |user|
        FactoryBot.create_list(:upvote, 10, user: user)
      end
    end
  end
end
