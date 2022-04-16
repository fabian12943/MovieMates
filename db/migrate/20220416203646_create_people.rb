class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.integer :tmdb_id, null: false, index: true
      t.string :language_iso_639_1, null: false
      t.boolean :complete, default: false

      # TMDB fields
      t.string :name, null: false
      t.text :biography
      t.boolean :adult
      t.string :also_known_as, array: true
      t.date :birthday
      t.date :deathday
      t.integer :gender
      t.string :homepage
      t.string :imdb_id
      t.string :known_for_department
      t.string :place_of_birth
      t.float :popularity
      t.string :profile_path

      t.timestamps

      t.index [:tmdb_id, :language_iso_639_1], unique: true
    end
  end
end
