class CreateMovieCastSets < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_cast_sets do |t|
      t.references :movie, foreign_key: true, null: false
      t.string :language_code, null: false

      t.jsonb :cast

      t.timestamps
    end
  end
end
