class CreateMovieRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_recommendations do |t|
      t.integer :movie_tmdb_id, null: false
      t.integer :recommendation_tmdb_id, null: false
      
      t.timestamps
    end
  end
end
