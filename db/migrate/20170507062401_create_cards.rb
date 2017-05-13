class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :hand
      t.references :game
      t.references :trick
      t.string :rank
      t.string :suit

      t.timestamps null: false
    end
  end
end
