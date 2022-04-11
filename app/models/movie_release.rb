class MovieRelease < ApplicationRecord
    belongs_to :movie
    
    alias_attribute :country_code, :iso_3166_1

    UPDATE_INTERVAL = 1.day

    def self.create_or_update(tmdb_id, country_code)
        movie_release = MovieRelease.find_by(movie_id: tmdb_id, country_code: country_code)
        if movie_release.nil? || movie_release.outdated_data? 
            if movie_release.nil?
                movie_release = MovieRelease.new
                movie_release.movie_id = tmdb_id
                movie_release.country_code = country_code
            end
            movie_release.update(country_code)
        end
    end

    def self.tmdb_map(tmdb_id)
        tmdb_map = Tmdb::Movie.releases(tmdb_id)

        if tmdb_map["status_code"] == 34
            raise TmdbErrors::ResourceNotFoundError.new("The movie with tmdb id #{self.movie_id} could not be found.")
        end
        tmdb_map
    end

    def update(country_code)
        tmdb_map = MovieRelease::tmdb_map(self.movie_id)
        tmdb_map["countries"].each do |country|
            if country["iso_3166_1"] == country_code
                self.release_date = country["release_date"]
                self.certification = country["certification"]
                break;
            end
        end
        self.changed? ? self.save : self.touch
    end

    def outdated_data?
        self.updated_at < UPDATE_INTERVAL.ago
    end

end
