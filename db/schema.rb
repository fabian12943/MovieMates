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

ActiveRecord::Schema[7.0].define(version: 2022_04_12_132642) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cast_detail_sets", force: :cascade do |t|
    t.bigint "cast_id", null: false
    t.string "language_code", null: false
    t.string "name", null: false
    t.boolean "adult"
    t.string "also_known_as", array: true
    t.text "biography"
    t.date "birthday"
    t.date "deathday"
    t.integer "gender"
    t.string "homepage"
    t.string "imdb_id"
    t.string "known_for_department"
    t.string "place_of_birth"
    t.float "popularity"
    t.string "profile_path"
    t.boolean "complete", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cast_id", "language_code"], name: "index_cast_detail_sets_on_cast_id_and_language_code", unique: true
    t.index ["cast_id"], name: "index_cast_detail_sets_on_cast_id"
  end

  create_table "casts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_backdrop_sets", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.string "file_paths", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_movie_backdrop_sets_on_movie_id"
  end

  create_table "movie_cast_sets", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.string "language_code", null: false
    t.jsonb "cast"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_movie_cast_sets_on_movie_id"
  end

  create_table "movie_detail_sets", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.string "language_code", null: false
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
    t.string "youtube_trailer_keys", array: true
    t.boolean "video"
    t.float "vote_average"
    t.integer "vote_count"
    t.boolean "complete", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id", "language_code"], name: "index_movie_detail_sets_on_movie_id_and_language_code", unique: true
    t.index ["movie_id"], name: "index_movie_detail_sets_on_movie_id"
  end

  create_table "movie_keyword_sets", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.string "keywords", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_movie_keyword_sets_on_movie_id"
  end

  create_table "movie_recommendation_sets", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.string "language_code", null: false
    t.integer "recommendation_movie_ids", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_movie_recommendation_sets_on_movie_id"
  end

  create_table "movie_releases", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.string "iso_3166_1"
    t.string "certification"
    t.datetime "release_date", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_movie_releases_on_movie_id"
  end

  create_table "movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "now_playing_movies", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_now_playing_movies_on_movie_id"
  end

  create_table "popular_movies", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_popular_movies_on_movie_id"
  end

  create_table "top_rated_movies", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_top_rated_movies_on_movie_id"
  end

  create_table "upcoming_movies", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_upcoming_movies_on_movie_id"
  end

  add_foreign_key "cast_detail_sets", "casts"
  add_foreign_key "movie_backdrop_sets", "movies"
  add_foreign_key "movie_cast_sets", "movies"
  add_foreign_key "movie_detail_sets", "movies"
  add_foreign_key "movie_keyword_sets", "movies"
  add_foreign_key "movie_recommendation_sets", "movies"
  add_foreign_key "movie_releases", "movies"
  add_foreign_key "now_playing_movies", "movies"
  add_foreign_key "popular_movies", "movies"
  add_foreign_key "top_rated_movies", "movies"
  add_foreign_key "upcoming_movies", "movies"
end
