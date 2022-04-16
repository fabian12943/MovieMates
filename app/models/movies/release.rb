class Movies::Release < ApplicationRecord
    self.table_name = "movie_releases"

    alias_attribute :country, :country_iso_3166_1
    has_many :movies, primary_key: :movie_tmdb_id, foreign_key: :tmdb_id

    VALIDITY_PERIOD = 1.day

    @@valid_tmdb_fields = %w(certification note release_date)

    enum type: { premiere: 1, limited_theatrical: 2, theatrical: 3, digital: 4, physical: 5, tv: 6 }

    def self.create_or_update_for_movie(movie, country)
        releases = Movies::Release.where(movie_tmdb_id: movie.tmdb_id, country: country)
        if releases.empty? || releases.minimum(:updated_at) < VALIDITY_PERIOD.ago
            releases.destroy_all
            Movies::Release.create_from_tmdb_request(movie, country)
        end
    end

    def self.create_from_tmdb_request(movie, country)
        tmdb_map = reduce_tmdb_map_to_country(tmdb_map(movie.tmdb_id), country)
        tmdb_map.each do |tmdb_release|
            release = Movies::Release.new(movie_tmdb_id: movie.tmdb_id)
            (valid_tmdb_fields).each do |valid_tmdb_field|
                release.send("#{valid_tmdb_field}=", tmdb_release[valid_tmdb_field])
            end
            release.release_type = tmdb_release["type"] # Column type is reserved for storing the class in case of inheritance in Active Record
            release.country = country
            release.save
        end
    end

    def self.valid_tmdb_fields
        @@valid_tmdb_fields
    end

    def self.tmdb_map(tmdb_id)
        tmdb_map = HTTParty.get("https://api.themoviedb.org/3/movie/#{tmdb_id}/release_dates?api_key=#{Rails.application.credentials.tmdb.api_key}")
        tmdb_map["results"]
    end

    def self.reduce_tmdb_map_to_country(tmdb_map, country)
        tmdb_map.select! { |release| release["iso_3166_1"] == country }
        return [] if tmdb_map.empty? # No releases for this country available
        tmdb_map[0]["release_dates"]
    end

    def self.get_theatrical_release
        all.where(release_type: Movies::Release.types[:theatrical]).first
    end

    def self.certification
        release = all.where.not(certification: nil).first
        release.certification if release
    end

end