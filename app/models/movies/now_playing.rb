class Movies::NowPlaying < ApplicationRecord
    self.table_name = "now_playing_movies"

    has_one :movie, primary_key: :movie_tmdb_id, foreign_key: :tmdb_id

    NUMBER_MOVIES = 40 # Best in steps of 20, since each request page has 20 entries

    def self.update
        Movies::NowPlaying.destroy_all

        updated_movies = 0
        page = 1
        while updated_movies < NUMBER_MOVIES
            tmdb_map = tmdb_map(page)
            tmdb_map.each do |movie|
                break if updated_movies >= NUMBER_MOVIES
                Movies::NowPlaying.create(movie_tmdb_id: movie["id"])
                updated_movies += 1
            end
            page += 1
        end

        create_or_update_movies_for_available_locales
    end

    def self.create_or_update_movies_for_available_locales
        I18n.available_locales.each do |language_code|
            updated_movies = 0
            page = 1
            while updated_movies < NUMBER_MOVIES
                tmdb_map = tmdb_map(page, language_code.to_s)
                Movies::Movie.create_or_update_movies_from_tmdb_map(tmdb_map, language_code.to_s, false)
                updated_movies += tmdb_map.size
                page += 1
            end
        end
    end

    def self.tmdb_map(page, language = "en")
        tmdb_map = HTTParty.get("https://api.themoviedb.org/3/movie/now_playing?language=#{language}&page=#{page}&api_key=#{Rails.application.credentials.tmdb[:api_key]}")
        tmdb_map["results"]
    end

    def self.movies
        Movies::Movie.where(tmdb_id: all.pluck(:movie_tmdb_id))
    end
    
end