class CreateNowPlayingMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :now_playing_movies do |t|
      t.integer :movie_tmdb_id, null: false
      
      t.timestamps
    end
  end
end
