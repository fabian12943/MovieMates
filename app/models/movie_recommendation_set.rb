class MovieRecommendationSet < ApplicationRecord
    belongs_to :movie

    UPDATE_INTERVAL = 1.day
    RECOMMENDATIONS_PER_FILM = 20

    def self.create_or_update(tmdb_id, language_code = I18n.locale)
        movie_recommendation_set = MovieRecommendationSet.find_by(movie_id: tmdb_id, language_code: language_code)
        if movie_recommendation_set.nil? || movie_recommendation_set.outdated_data?
            if movie_recommendation_set.nil?
                movie_recommendation_set = MovieRecommendationSet.new
                movie_recommendation_set.movie_id = tmdb_id
                movie_recommendation_set.language_code = language_code
            end
            movie_recommendation_set.update
        end
    end

    def self.tmdb_map(tmdb_id, language_code = I18n.locale)
        tmdb_map = Tmdb::Movie.detail(tmdb_id, language: language_code, append_to_response: "recommendations")
        if tmdb_map["status_code"] == 34
            raise TmdbErrors::ResourceNotFoundError.new("The movie with tmdb id #{self.movie_id} could not be found.")
        end
        tmdb_map["recommendations"]
    end

    def update
        tmdb_map = MovieRecommendationSet::tmdb_map(self.movie_id, self.language_code)
        self.recommendation_movie_ids = tmdb_map["results"].first(RECOMMENDATIONS_PER_FILM).map { |recommendation| recommendation["id"] }
        MovieDetailSet.create_or_update_basic_details_of_movies_from_json(tmdb_map, self.language_code)
        self.changed? ? self.save : self.touch
    end

    def outdated_data?
        self.updated_at < UPDATE_INTERVAL.ago
    end

    after_update_commit { broadcast_update_to("movie", target: "recommendations_#{self.movie_id}_#{self.language_code}", partial: 'movies/recommendations', locals: { recommendation_set: self }) }
    after_create_commit { broadcast_update_to("movie", target: "recommendations_#{self.movie_id}_#{self.language_code}", partial: 'movies/recommendations', locals: { recommendation_set: self }) }
    
end
