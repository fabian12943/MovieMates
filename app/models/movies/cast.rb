class Movies::Cast < ApplicationRecord
    self.table_name = "movie_casts"

    has_many :movies, class_name: "Movies::Movie", primary_key: :movie_tmdb_id, foreign_key: :tmdb_id
    has_many :persons, class_name: "People::Person", primary_key: :person_tmdb_id, foreign_key: :tmdb_id

    VALIDITY_PERIOD = 1.day

    @@valid_tmdb_fields = %w(character order)

    def self.create_or_update_for_movie(movie)
        casts = Movies::Cast.where(movie_tmdb_id: movie.tmdb_id)
        if casts.empty? || casts.minimum(:updated_at) < VALIDITY_PERIOD.ago
            casts.destroy_all
            Movies::Cast.create_from_tmdb_request(movie)
        end

        create_or_update_casted_people_of_movie(movie)
    end

    def self.create_from_tmdb_request(movie)
        tmdb_map = tmdb_map(movie.tmdb_id, movie.language)
        tmdb_map.each do |tmdb_cast|
            cast = Movies::Cast.new(movie_tmdb_id: movie.tmdb_id, person_tmdb_id: tmdb_cast["id"])
            (valid_tmdb_fields).each do |valid_tmdb_field|
                cast.send("#{valid_tmdb_field}=", tmdb_cast[valid_tmdb_field])
            end
            cast.save
        end
    end

    def self.create_or_update_casted_people_of_movie(movie)
        tmdb_map = tmdb_map(movie.tmdb_id, movie.language)
        People::Person.create_or_update_people_from_tmdb_map(tmdb_map, movie.language, false)
    end

    def self.tmdb_map(tmdb_id, language)
        tmdb_map = HTTParty.get("https://api.themoviedb.org/3/movie/#{tmdb_id}/credits?language=#{language}&api_key=#{Rails.application.credentials.tmdb.api_key}")
        tmdb_map["cast"]
    end

    def self.valid_tmdb_fields
        @@valid_tmdb_fields
    end

    def character_translated
        return "" if character.blank?
        self[:character].gsub(/\(voice\)/, "(#{I18n.t('movies.cast.voice')})")
                        .gsub(/\(Encore\)/, "(#{I18n.t('movies.cast.encore')})")
                        .gsub(/Himself/, "#{I18n.t('movies.cast.himself')}")
                        .gsub(/Herself/, "#{I18n.t('movies.cast.herself')}")
                        .gsub(/Self/, "#{I18n.t('movies.cast.self')}")
                        .gsub(/\(uncredited\)/, '')
                        .gsub(/\(archive footage\)/, '')
    end

end