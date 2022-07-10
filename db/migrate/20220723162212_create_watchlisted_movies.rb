class CreateWatchlistedMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :watchlisted_movies do |t|
      t.integer :movie_tmdb_id, null: false
      t.references :watchlist, null: false

      t.timestamps
    end
  end
end
