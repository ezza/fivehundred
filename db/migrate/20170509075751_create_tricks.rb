class CreateTricks < ActiveRecord::Migration
  def change
    create_table :tricks do |t|
      t.references :game

      t.integer :won_by_hand_id

      t.timestamps null: false
    end
  end
end
