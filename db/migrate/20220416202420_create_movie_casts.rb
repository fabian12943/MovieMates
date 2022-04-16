class CreateMovieCasts < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_casts do |t|
      t.integer :movie_tmdb_id, null: false
      t.integer :person_tmdb_id, null: false

      # TMDB fields
      t.string :character
      t.integer :order

      t.timestamps
    end
  end
end
