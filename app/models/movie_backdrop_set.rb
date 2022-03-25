class MovieBackdropSet < ApplicationRecord
    belongs_to :movie

    UPDATE_INTERVAL = 1.day

    def self.create_or_update(tmdb_id)
        movie_backdrop_set = MovieBackdropSet.find_by(movie_id: tmdb_id)
        if movie_backdrop_set.nil? || movie_backdrop_set.outdated_data?
            if movie_backdrop_set.nil?
                movie_backdrop_set = MovieBackdropSet.new
                movie_backdrop_set.movie_id = tmdb_id
            end
            movie_backdrop_set.update
        end
    end

    def self.tmdb_map(tmdb_id)
        tmdb_map = Tmdb::Movie.images(tmdb_id)
        if tmdb_map["status_code"] == 34
            raise "The resource with tmdb id #{tmdb_id} could not be found."
        end
        tmdb_map["backdrops"]
    end

    def update
        tmdb_map = MovieBackdropSet::tmdb_map(self.movie_id)
        self.file_paths = []
        tmdb_map.each do |backdrop|
            self.file_paths << backdrop["file_path"]
        end
        self.changed? ? self.save : self.touch
    end

    def outdated_data?
        self.updated_at < UPDATE_INTERVAL.ago
    end
    
end
