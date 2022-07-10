class WatchlistedMovie < ApplicationRecord
  has_many :movies, class_name: "Movies::Movie", primary_key: :movie_tmdb_id, foreign_key: :tmdb_id
  belongs_to :watchlist
end