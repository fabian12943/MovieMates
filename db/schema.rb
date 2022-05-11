# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_05_10_204012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "movie_backdrops", force: :cascade do |t|
    t.integer "movie_tmdb_id", null: false
    t.float "aspect_ratio"
    t.integer "height"
    t.string "iso_639_1"
    t.string "file_path", null: false
    t.float "vote_average"
    t.integer "vote_count"
    t.integer "width"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_casts", force: :cascade do |t|
    t.integer "movie_tmdb_id", null: false
    t.integer "person_tmdb_id", null: false
    t.string "character"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_keywords", force: :cascade do |t|
    t.integer "movie_tmdb_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_recommendations", force: :cascade do |t|
    t.integer "movie_tmdb_id", null: false
    t.integer "recommendation_tmdb_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_releases", force: :cascade do |t|
    t.integer "movie_tmdb_id", null: false
    t.string "country_iso_3166_1", null: false
    t.string "certification"
    t.string "note"
    t.date "release_date"
    t.string "release_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_videos", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.string "name"
    t.string "key"
    t.string "site"
    t.integer "size"
    t.string "video_type"
    t.boolean "offical"
    t.date "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_movie_videos_on_movie_id"
  end

  create_table "movies", force: :cascade do |t|
    t.integer "tmdb_id", null: false
    t.string "language_iso_639_1", null: false
    t.boolean "complete", default: false
    t.text "title", null: false
    t.text "overview"
    t.boolean "adult"
    t.string "backdrop_path"
    t.jsonb "belongs_to_collection"
    t.bigint "budget"
    t.jsonb "genres"
    t.string "homepage"
    t.string "imdb_id"
    t.string "original_language"
    t.text "original_title"
    t.float "popularity"
    t.string "poster_path"
    t.jsonb "production_companies"
    t.jsonb "production_countries"
    t.date "release_date"
    t.bigint "revenue"
    t.integer "runtime"
    t.jsonb "spoken_languages"
    t.string "status"
    t.text "tagline"
    t.boolean "video"
    t.float "vote_average"
    t.integer "vote_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tmdb_id", "language_iso_639_1"], name: "index_movies_on_tmdb_id_and_language_iso_639_1", unique: true
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id"
  end

  create_table "now_playing_movies", force: :cascade do |t|
    t.integer "movie_tmdb_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.integer "tmdb_id", null: false
    t.string "language_iso_639_1", null: false
    t.boolean "complete", default: false
    t.string "name", null: false
    t.text "biography"
    t.boolean "adult"
    t.string "also_known_as", array: true
    t.date "birthday"
    t.date "deathday"
    t.integer "gender"
    t.string "homepage"
    t.string "imdb_id"
    t.string "known_for_department"
    t.string "place_of_birth"
    t.float "popularity"
    t.string "profile_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tmdb_id", "language_iso_639_1"], name: "index_people_on_tmdb_id_and_language_iso_639_1", unique: true
    t.index ["tmdb_id"], name: "index_people_on_tmdb_id"
  end

  create_table "person_external_ids_sets", force: :cascade do |t|
    t.integer "person_tmdb_id", null: false
    t.string "imdb_id"
    t.string "facebook_id"
    t.string "instagram_id"
    t.string "twitter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "person_movie_credits", force: :cascade do |t|
    t.integer "person_tmdb_id", null: false
    t.integer "movie_tmdb_id", null: false
    t.string "character"
    t.boolean "voice", default: false
    t.integer "order"
    t.date "release_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_tmdb_id", "movie_tmdb_id"], name: "index_person_movie_credits_on_person_tmdb_id_and_movie_tmdb_id", unique: true
  end

  create_table "person_news_articles", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "title"
    t.string "description"
    t.string "url"
    t.string "image"
    t.date "publishedAt"
    t.jsonb "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_person_news_articles_on_person_id"
  end

  create_table "popular_movies", force: :cascade do |t|
    t.integer "movie_tmdb_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "popular_people", force: :cascade do |t|
    t.integer "person_tmdb_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "top_rated_movies", force: :cascade do |t|
    t.integer "movie_tmdb_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "upcoming_movies", force: :cascade do |t|
    t.integer "movie_tmdb_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid"
    t.string "provider"
  end

end
