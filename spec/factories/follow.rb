FactoryBot.define do
  factory :follow do
    author { create :author }
    user { create :user }
  end
end
