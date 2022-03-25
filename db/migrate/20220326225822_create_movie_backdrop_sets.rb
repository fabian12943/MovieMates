class CreateMovieBackdropSets < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_backdrop_sets do |t|
      t.references :movie, foreign_key: true, null: false

      t.string :file_paths, array: true

      t.timestamps
    end
  end
end
