class Watchlist < ApplicationRecord

  validates :name, presence: true, length: { minimum: 5, maximum: 50 }
  validates :description, presence: true, length: { minimum: 5, maximum: 200 }

  has_one :user, primary_key: :user_id, foreign_key: :id
  has_many :watchlisted_movies, primary_key: :id, foreign_key: :watchlist_id, dependent: :destroy
  has_many :movies, class_name: "Movies::Movie", primary_key: :movie_tmdb_id, foreign_key: :tmdb_id, through: :watchlisted_movies

  before_validation { self.name.strip!; self.description.strip! }

  def to_param
    return nil unless persisted?
    [id, name].join('-').parameterize
  end

  def picture_path(image_size = "original")
    if self.movies.size > 0
      self.watchlisted_movies.order(:created_at).first(5).each do |watchlisted_movie|
        movie = watchlisted_movie.movies.first
        if movie.backdrops.present?
          backdrop_file_path = movie.backdrops.first.file_path
          return Tmdb::Configuration.new.secure_base_url + "#{image_size}" + backdrop_file_path
        end
      end
    end
    return nil
  end

end