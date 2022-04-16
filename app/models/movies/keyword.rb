class Movies::Keyword < ApplicationRecord
    self.table_name = "movie_keywords"

    has_many :movies, primary_key: :movie_tmdb_id, foreign_key: :tmdb_id

    VALIDITY_PERIOD = 1.day
    MAX_KEYWORDS_PER_MOVIE = 10

    @@valid_tmdb_fields = %w(name)

    def self.create_or_update_for_movie(movie)
        keywords = Movies::Keyword.where(movie_tmdb_id: movie.tmdb_id)
        if keywords.empty? || keywords.minimum(:updated_at) < VALIDITY_PERIOD.ago
            keywords.destroy_all
            Movies::Keyword.create_from_tmdb_request(movie)
        end
    end

    def self.create_from_tmdb_request(movie)
        tmdb_map = tmdb_map(movie.tmdb_id)
        tmdb_map.each_with_index do |tmdb_backdrop, index|
            break if index >= MAX_KEYWORDS_PER_MOVIE
            keyword = Movies::Keyword.new(movie_tmdb_id: movie.tmdb_id)
            (valid_tmdb_fields).each do |valid_tmdb_field|
                keyword.send("#{valid_tmdb_field}=", tmdb_backdrop[valid_tmdb_field])
            end
            keyword.save
        end
    end

    def self.valid_tmdb_fields
        @@valid_tmdb_fields
    end

    def self.tmdb_map(tmdb_id)
        Tmdb::Movie.keywords(tmdb_id)["keywords"]
    end

end