class CreateBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :books do |t|
      t.string :title
      t.datetime :published_on
      t.references :author, foreign_key: true

      t.timestamps
    end
  end
end
