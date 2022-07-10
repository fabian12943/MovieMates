class CreateWatchlists < ActiveRecord::Migration[7.0]
  def change
    create_table :watchlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false
      t.boolean :private, default: false
      
      t.timestamps
    end
  end
end
