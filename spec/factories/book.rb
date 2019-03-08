FactoryBot.define do
  factory :book do
    author { create :author }
    title { Faker::Book.title }
    genres { [Faker::Book.genre, Faker::Book.genre] }
  end
end
