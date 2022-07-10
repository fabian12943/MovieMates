class Movies::UserRating < ApplicationRecord
  self.table_name = "movie_user_ratings"    
  
  has_many :movies, class_name: "Movies::Movie", primary_key: :movie_tmdb_id, foreign_key: :tmdb_id
  belongs_to :user
end