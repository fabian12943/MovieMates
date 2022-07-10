class CreateMovieUserRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_user_ratings do |t|
      t.belongs_to :user
      t.integer :movie_tmdb_id, null: false

      t.float :rating, null: false

      t.timestamps
    end
  end
end
