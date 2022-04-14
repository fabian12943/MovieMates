class CreateTopRatedMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :top_rated_movies do |t|
      t.references :movie, foreign_key: true, null: false
      
      t.timestamps
    end
  end
end
