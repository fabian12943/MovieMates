class CreateMovieDetailSets < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_detail_sets do |t|
      t.references :movie, foreign_key: true, null: false
      t.string :language_code, null: false

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
      t.string :youtube_trailer_keys, array: true 
      t.boolean :video
      t.float :vote_average
      t.integer :vote_count

      t.timestamps
    end
  end
end
