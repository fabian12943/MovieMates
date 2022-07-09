class SeenMovie < ApplicationRecord

  has_many :movies, primary_key: :movie_tmdb_id, foreign_key: :tmdb_id, class_name: "Movies::Movie"
  belongs_to :user
  
  validates :user_id, presence: true
  validates :movie_tmdb_id, presence: true
  validates :user_id, uniqueness: { scope: :movie_tmdb_id }

end