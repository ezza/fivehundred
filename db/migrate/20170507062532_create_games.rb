class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :match

      t.integer :bid_winner_id

      t.string :trump_suit
      t.integer :tricks_bid
      t.integer :tricks_won
      t.boolean :started, default: false
      t.boolean :played, default: false

      t.timestamps null: false
    end
  end
end
