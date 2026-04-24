class CreateQuoteHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :quote_histories do |t|
      t.date :date, null: false
      t.references :quote, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :quote_histories, :date, unique: true
  end
end
