class CreatePersonNewsArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :person_news_articles do |t|
      t.references :person, null: false

      # GNews fields
      t.string :title
      t.string :description
      t.string :url
      t.string :image
      t.date :publishedAt
      t.jsonb :source

      t.timestamps
    end
  end
end
