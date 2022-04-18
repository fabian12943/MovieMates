class Movies::Backdrop < ApplicationRecord
    self.table_name = "movie_backdrops"

    alias_attribute :language, :iso_639_1
    has_many :movies, primary_key: :movie_tmdb_id, foreign_key: :tmdb_id

    VALIDITY_PERIOD = 1.day
    MAX_BACKDROPS_PER_MOVIE = 20

    @@valid_tmdb_fields = %w(aspect_ratio height iso_639_1 file_path vote_average vote_count width)

    def self.create_or_update_for_movie(movie)
        backdrops = Movies::Backdrop.where(movie_tmdb_id: movie.tmdb_id)
        if backdrops.empty? || backdrops.minimum(:updated_at) < VALIDITY_PERIOD.ago
            backdrops.destroy_all
            Movies::Backdrop.create_from_tmdb_request(movie)
        end
    end

    def self.create_from_tmdb_request(movie)
        tmdb_map = tmdb_map(movie.tmdb_id)
        tmdb_map.each_with_index do |tmdb_backdrop, index|
            break if index >= MAX_BACKDROPS_PER_MOVIE
            backdrop = Movies::Backdrop.new(movie_tmdb_id: movie.tmdb_id)
            (valid_tmdb_fields).each do |valid_tmdb_field|
                backdrop.send("#{valid_tmdb_field}=", tmdb_backdrop[valid_tmdb_field])
            end
            backdrop.save
        end
    end

    def self.valid_tmdb_fields
        @@valid_tmdb_fields
    end

    def self.tmdb_map(tmdb_id)
        Tmdb::Movie.images(tmdb_id)["backdrops"]
    end

    def self.of_language(language)
        all.where(language: [language, nil])
    end

end