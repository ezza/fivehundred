class CreateMatchUsers < ActiveRecord::Migration
  def change
    create_table :match_users do |t|
      t.references :user
      t.references :match
      t.integer :score, default: 0, null:  false

      t.timestamps null: false
    end
  end
end
