class CreateBookRecommendations < ActiveRecord::Migration[5.1]
  def change
    create_table :book_recommendations do |t|
      t.references :user, foreign_key: true, index: { unique: true }
      t.json :book_ids

      t.timestamps
    end
  end
end
