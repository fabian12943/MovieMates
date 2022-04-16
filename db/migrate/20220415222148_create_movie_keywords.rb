class CreateMovieKeywords < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_keywords do |t|
      t.integer :movie_tmdb_id, null: false

      # TMDB fields
      t.string :name

      t.timestamps
    end
  end
end
