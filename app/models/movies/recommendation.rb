class Movies::Recommendation < ApplicationRecord
    self.table_name = "movie_recommendations"

    has_one :movie, class_name: "Movies::Movie", primary_key: :movie_tmdb_id, foreign_key: :tmdb_id
    has_many :recommended_movies, class_name: "Movies::Movie", primary_key: :recommendation_tmdb_id, foreign_key: :tmdb_id

    VALIDITY_PERIOD = 1.day

    def self.create_or_update_for_movie(movie)
        recommendations = Movies::Recommendation.where(movie_tmdb_id: movie.tmdb_id)
        if recommendations.empty? || recommendations.minimum(:updated_at) < VALIDITY_PERIOD.ago
            recommendations.destroy_all
            Movies::Recommendation.create_from_tmdb_request(movie)
        end

        create_or_update_recommended_movies_of_movie(movie)
    end

    def self.create_from_tmdb_request(movie)
        tmdb_map = tmdb_map(movie.tmdb_id, movie.language)
        tmdb_map.each do |tmdb_recommendation|
            recommendation = Movies::Recommendation.create(movie_tmdb_id: movie.tmdb_id, recommendation_tmdb_id: tmdb_recommendation["id"])
        end
    end

    def self.create_or_update_recommended_movies_of_movie(movie)
        tmdb_map = tmdb_map(movie.tmdb_id, movie.language)
        Movies::Movie.create_or_update_movies_from_tmdb_map(tmdb_map, movie.language, false)
    end

    def self.tmdb_map(tmdb_id, language)
        tmdb_map = HTTParty.get("https://api.themoviedb.org/3/movie/#{tmdb_id}/recommendations?language=#{language}&api_key=#{Rails.application.credentials.tmdb.api_key}")
        tmdb_map["results"]
    end

end