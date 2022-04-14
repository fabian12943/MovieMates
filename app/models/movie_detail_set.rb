class MovieDetailSet < ApplicationRecord
    belongs_to :movie

    UPDATE_INTERVAL = 1.day

    REQUIRED_ATTRIBUTES = ['id', 'movie_id', 'language_code', 'created_at', 'updated_at']
    BASIC_ATTRIBUTES = ['title', 'poster_path', 'vote_average', 'vote_count', 'release_date', 'popularity']

    def self.create_or_update_all_details_of_movie(tmdb_id, language_code, only_basic_details = false)
        movie_detail_set = MovieDetailSet.find_by(movie_id: tmdb_id, language_code: language_code)
        if movie_detail_set.nil? || movie_detail_set.outdated_data? || (movie_detail_set.complete == false && only_basic_details == false)
            movie_detail_set = MovieDetailSet.add_required_attributes(tmdb_id, language_code) if movie_detail_set.nil?
            movie_detail_set.update_details_by_request(only_basic_details)
        end
    end

    def self.create_or_update_all_details_of_movies(tmdb_ids, language_code, only_basic_details = false)
        threads = []
        tmdb_ids.each do |tmdb_id| 
            threads << Thread.new do
                self.create_or_update_all_details_of_movie(tmdb_id, language_code, only_basic_details)
                ActiveRecord::Base.connection.close
            end
        end
        threads.each(&:join)
        I18n.locale = language_code # TODO: Temporary Fix: Locale get lost after threads are finished
    end

    def self.create_or_update_basic_details_of_movies_from_json(json, language_code)
        threads = []
        json["results"].each do |movie_json| 
            threads << Thread.new do
                movie_id = movie_json["id"]
                movie_detail_set = MovieDetailSet.find_by(movie_id: movie_id, language_code: language_code)
                if movie_detail_set.nil? || movie_detail_set.outdated_data?
                    movie_detail_set = MovieDetailSet.add_required_attributes(movie_id, language_code) if movie_detail_set.nil?
                    movie_detail_set.update_basic_details_of_movie_from_json(movie_json)
                end
                ActiveRecord::Base.connection.close
            end
        end
        threads.each(&:join)
        I18n.locale = language_code # TODO: Temporary Fix: Locale get lost after threads are finished
    end

    def rating_classification
        return "no-votes" if self.vote_count == 0
        case self.vote_average
        when 0...5
            "bad"
        when 5...7
            "average"
        when 7...8
            "good"
        when 8..10
            "excellent"
        end
    end

    def picture_path(image_size = "original")
        return nil if self.poster_path.blank?
        Tmdb::Configuration.new.secure_base_url + "#{image_size}" + self.poster_path
    end

    def picture_placeholder
        "no_image_placeholder.svg"
    end

    
    def outdated_data?
        self.updated_at < UPDATE_INTERVAL.ago
    end

    def self.add_required_attributes(movie_id, language_code)
        Movie.create(id: movie_id) if Movie.exists?(movie_id) == false
        movie_detail_set = MovieDetailSet.new
        movie_detail_set.movie_id = movie_id
        movie_detail_set.language_code = language_code
        movie_detail_set
    end

    def update_details_by_request(only_basic_details)
        tmdb_details_map = self.tmdb_details_map
        only_basic_details ? self.update_basic_details_of_movie_from_json(tmdb_details_map) : self.update_all_details_of_movie_from_json(tmdb_details_map)
    end

    def update_basic_details_of_movie_from_json(json)
        (BASIC_ATTRIBUTES).each do |column_name|
            self.send("#{column_name}=", json[column_name])
        end
        self.complete = false
        self.changed? ? self.save : self.touch
    end

    def update_all_details_of_movie_from_json(json)
        (MovieDetailSet.column_names - REQUIRED_ATTRIBUTES - ['trailers']).each do |column_name|
            self.send("#{column_name}=", json[column_name])
        end
        self.youtube_trailer_keys = json["trailers"]["youtube"].map { |trailer| trailer["source"] if trailer["type"] == "Trailer" }.compact
        self.complete = true
        self.changed? ? self.save : self.touch
    end

    def tmdb_details_map
        tmdb_map = Tmdb::Movie.detail(self.movie_id, language: language_code, append_to_response: "trailers")
        if tmdb_map["status_code"] == 34
            raise TmdbErrors::ResourceNotFoundError.new("The movie with tmdb id #{self.movie_id} could not be found.")
        end
        tmdb_map
    end

end
