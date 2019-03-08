FactoryBot.define do
  factory :upvote do
    user { create :user }
    book { create :book }
  end
end
