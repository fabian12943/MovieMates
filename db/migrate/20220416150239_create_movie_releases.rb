class CreateMovieReleases < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_releases do |t|
      t.integer :movie_tmdb_id, null: false
      t.string :country_iso_3166_1, null: false

      # TMDB fields
      t.string :certification
      t.string :note
      t.date :release_date
      t.string :release_type

      t.timestamps
    end
  end
end
