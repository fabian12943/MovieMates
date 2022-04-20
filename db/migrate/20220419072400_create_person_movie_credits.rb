class CreatePersonMovieCredits < ActiveRecord::Migration[7.0]
  def change
    create_table :person_movie_credits do |t|
      t.integer :person_tmdb_id, null: false
      t.integer :movie_tmdb_id, null: false

      # TMDB fields
      t.string :character
      t.boolean :voice, default: false
      t.integer :order
      t.date :release_date

      t.timestamps

      t.index [:person_tmdb_id, :movie_tmdb_id], unique: true
    end
  end
end
