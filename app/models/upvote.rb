class Upvote < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates_uniqueness_of :user, scope: :book
end
