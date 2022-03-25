class CreateMovieRecommendationSets < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_recommendation_sets do |t|
      t.references :movie, foreign_key: true, null: false
      t.string :language_code, null: false

      t.integer :recommendation_movie_ids, array: true

      t.timestamps
    end
  end
end
