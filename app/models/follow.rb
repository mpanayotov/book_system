class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :author

  validates_uniqueness_of :user, scope: :author
end
