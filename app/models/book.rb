class Book < ApplicationRecord
  belongs_to :author
  has_many :upvotes

  scope :most_upvoted, -> do
    joins(:upvotes)
    .select('count(*) as upvotes, books.*')
    .group(:id)
    .order('upvotes desc')
  end
end
