class CreateHands < ActiveRecord::Migration
  def change
    create_table :hands do |t|
      t.references :game

      t.timestamps null: false
    end
  end
end
