class MovieDetailSet < ApplicationRecord
    belongs_to :movie

    UPDATE_INTERVAL = 1.day

    def self.create_or_update(tmdb_id, language_code = I18n.locale)
        movie_detail_set = MovieDetailSet.find_by(movie_id: tmdb_id, language_code: language_code)
        if movie_detail_set.nil? || movie_detail_set.outdated_data?
            if movie_detail_set.nil?
                movie_detail_set = MovieDetailSet.new
                movie_detail_set.movie_id = tmdb_id
                movie_detail_set.language_code = language_code
            end
            movie_detail_set.update
        end
    end

    def self.tmdb_map(tmdb_id, language_code = I18n.locale)
        tmdb_map = Tmdb::Movie.detail(tmdb_id, language: language_code, append_to_response: "trailers")
        if tmdb_map["status_code"] == 34
            raise "The resource with tmdb id #{tmdb_id} could not be found."
        end
        tmdb_map
    end

    def update
        tmdb_map = MovieDetailSet::tmdb_map(self.movie_id, self.language_code)
        (MovieDetailSet.column_names - ['id', 'movie_id', 'language_code', 'trailers', 'created_at', 'updated_at']).each do |column_name|
            self.send("#{column_name}=", tmdb_map[column_name])
        end
        self.youtube_trailer_keys = tmdb_map["trailers"]["youtube"].map { |trailer| trailer["source"] if trailer["type"] == "Trailer" }.compact
        self.changed? ? self.save : self.touch
    end

    def outdated_data?
        self.updated_at < UPDATE_INTERVAL.ago
    end

    def self.create_several(tmdb_ids, language_code = I18n.locale)
        threads = []
        tmdb_ids.each do |tmdb_id| 
            threads << Thread.new do
                Movie::create(id: tmdb_id) if Movie.exists?(tmdb_id) == false
                MovieDetailSet::create_or_update(tmdb_id, language_code)
                ActiveRecord::Base.connection.close
            end
        end
        threads.each(&:join)
    end

end
