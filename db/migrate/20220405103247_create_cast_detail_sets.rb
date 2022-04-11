class CreateCastDetailSets < ActiveRecord::Migration[7.0]
  def change
    create_table :cast_detail_sets do |t|
      t.references :cast, foreign_key: true, null: false
      t.string :language_code, null: false

      t.string :name, null: false
      t.boolean :adult
      t.string :also_known_as, array: true
      t.text :biography
      t.date :birthday
      t.date :deathday
      t.integer :gender
      t.string :homepage
      t.string :imdb_id
      t.string :known_for_department
      t.string :place_of_birth
      t.float :popularity
      t.string :profile_path

      t.boolean :complete, default: false

      t.timestamps

      t.index [:cast_id, :language_code], unique: true
    end
  end
end