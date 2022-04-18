class CreatePersonExternalIdsSets < ActiveRecord::Migration[7.0]
  def change
    create_table :person_external_ids_sets do |t|
      t.integer :person_tmdb_id, null: false

      # TMDB fields
      t.string :imdb_id
      t.string :facebook_id
      t.string :instagram_id
      t.string :twitter_id

      t.timestamps
    end
  end
end
