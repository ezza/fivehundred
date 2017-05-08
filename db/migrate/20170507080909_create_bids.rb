class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.references :hand
      t.references :game

      t.string :suit
      t.integer :tricks
      t.boolean :won

      t.timestamps null: false
    end
  end
end
