class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :trump_suit
      t.integer :tricks_bid
      t.integer :tricks_won

      t.timestamps null: false
    end
  end
end
