class CreateMovieVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_videos do |t|
      t.references :movie, null: false

      # TMDB fields
      t.string :name
      t.string :key
      t.string :site
      t.integer :size
      t.string :video_type
      t.boolean :offical
      t.date :published_at

      t.timestamps
    end
  end
end
