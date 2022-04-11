class MovieKeywordSet < ApplicationRecord
    belongs_to :movie

    UPDATE_INTERVAL = 1.day

    def self.create_or_update(tmdb_id)
        movie_keyword_set = MovieKeywordSet.find_by(movie_id: tmdb_id)
        if movie_keyword_set.nil? || movie_keyword_set.outdated_data? 
            if movie_keyword_set.nil?
                movie_keyword_set = MovieKeywordSet.new
                movie_keyword_set.movie_id = tmdb_id
            end
            movie_keyword_set.update
        end
    end

    def self.tmdb_map(tmdb_id)
        tmdb_map = Tmdb::Movie.keywords(tmdb_id)
        if tmdb_map["status_code"] == 34
            raise TmdbErrors::ResourceNotFoundError.new("The movie with tmdb id #{self.movie_id} could not be found.")
        end
        tmdb_map
    end

    def update
        tmdb_map = MovieKeywordSet::tmdb_map(self.movie_id)
        self.keywords = []
        tmdb_map["keywords"].each do |keyword|
            self.keywords << keyword["name"]
        end
        self.changed? ? self.save : self.touch
    end

    def outdated_data?
        self.updated_at < UPDATE_INTERVAL.ago
    end

end
