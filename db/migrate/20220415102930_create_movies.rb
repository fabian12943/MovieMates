class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies do |t|
      t.integer :tmdb_id, null: false, index: true
      t.string :language_iso_639_1, null: false
      t.boolean :complete, default: false

      # TMDB fields
      t.text :title, null: false
      t.text :overview
      t.boolean :adult
      t.string :backdrop_path
      t.jsonb :belongs_to_collection
      t.bigint :budget
      t.jsonb :genres
      t.string :homepage
      t.string :imdb_id
      t.string :original_language
      t.text :original_title
      t.float :popularity
      t.string :poster_path
      t.jsonb :production_companies
      t.jsonb :production_countries
      t.date :release_date
      t.bigint :revenue
      t.integer :runtime
      t.jsonb :spoken_languages
      t.string :status
      t.text :tagline
      t.boolean :video
      t.float :vote_average
      t.integer :vote_count

      t.timestamps
      
      t.index [:tmdb_id, :language_iso_639_1], unique: true
    end
  end
end
