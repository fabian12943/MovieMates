class CreateSeenMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :seen_movies do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :movie_tmdb_id, null: false
      
      t.timestamps
    end
  end
end
