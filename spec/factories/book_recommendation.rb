FactoryBot.define do
  factory :book_recommendation do
    book_ids { (1..99).to_a.sample(3) }
    user { create :user }
  end
end
