class CreateHands < ActiveRecord::Migration
  def change
    create_table :hands do |t|
      t.references :game
      t.references :user

      t.integer :bid_order

      t.timestamps null: false
    end
  end
end
