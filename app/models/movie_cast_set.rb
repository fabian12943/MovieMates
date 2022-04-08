class MovieCastSet < ApplicationRecord
    belongs_to :movie

    UPDATE_INTERVAL = 1.day
    PERSONS_PER_MOVIE = 20

    def self.create_or_update(tmdb_id, language_code = I18n.locale)
        movie_cast_set = MovieCastSet.find_by(movie_id: tmdb_id, language_code: language_code)
        if movie_cast_set.nil? || movie_cast_set.outdated_data?
            if movie_cast_set.nil?
                movie_cast_set = MovieCastSet.new
                movie_cast_set.movie_id = tmdb_id
                movie_cast_set.language_code = language_code
            end
            movie_cast_set.update
        end
    end

    def self.tmdb_map(tmdb_id, language_code = I18n.locale)
        tmdb_map = Tmdb::Movie.detail(tmdb_id, language: language_code, append_to_response: "credits")
        if tmdb_map["status_code"] == 34
            raise "The resource with tmdb id #{tmdb_id} could not be found."
        end
        tmdb_map["credits"]
    end

    def update
        tmdb_map = MovieCastSet::tmdb_map(self.movie_id, self.language_code)
        self.cast = JSON.parse(tmdb_map["cast"].first(PERSONS_PER_MOVIE).to_json(only: ["id", "character"]))

        CastDetailSet.create_several(self.cast.map { |person| person["id"] }, self.language_code)
        
        self.changed? ? self.save : self.touch
        
    end

    def outdated_data?
        self.updated_at < UPDATE_INTERVAL.ago
    end

    def character(cast_id)
        character = self.cast.find { |person| person["id"] == cast_id }["character"]
        character.gsub!(/\(\w*\)/, '')
    end

    after_update_commit { broadcast_update_to("movie", target: "casts_#{self.movie_id}_#{self.language_code}", partial: 'movies/cast', locals: { cast_set: self }) }
    after_create_commit { broadcast_update_to("movie", target: "casts_#{self.movie_id}_#{self.language_code}", partial: 'movies/cast', locals: { cast_set: self }) }
    
end
