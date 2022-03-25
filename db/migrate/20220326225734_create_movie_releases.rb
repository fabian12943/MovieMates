class CreateMovieReleases < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_releases do |t|
      t.references :movie, foreign_key: true, null: false

      t.string :iso_3166_1
      t.string :certification
      t.timestamp :release_date

      t.timestamps
    end
  end
end
