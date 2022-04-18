class CreatePopularPeople < ActiveRecord::Migration[7.0]
  def change
    create_table :popular_people do |t|
      t.integer :person_tmdb_id, null: false

      t.timestamps
    end
  end
end
