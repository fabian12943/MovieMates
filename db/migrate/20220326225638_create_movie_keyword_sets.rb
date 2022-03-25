class CreateMovieKeywordSets < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_keyword_sets do |t|
      t.references :movie, foreign_key: true, null: false

      t.string :keywords, array: true

      t.timestamps
    end
  end
end
