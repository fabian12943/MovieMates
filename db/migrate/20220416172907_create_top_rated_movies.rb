class CreateTopRatedMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :top_rated_movies do |t|
      t.integer :movie_tmdb_id, null: false
      
      t.timestamps
    end
  end
end
