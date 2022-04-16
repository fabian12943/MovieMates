class CreateMovieBackdrops < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_backdrops do |t|
      t.integer :movie_tmdb_id, null: false

      # TMDB fields
      t.float :aspect_ratio
      t.integer :height
      t.string :iso_639_1
      t.string :file_path, null: false
      t.float :vote_average
      t.integer :vote_count
      t.integer :width

      t.timestamps
    end
  end
end
