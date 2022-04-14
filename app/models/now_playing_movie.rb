class NowPlayingMovie < ApplicationRecord
    UPDATE_INTERVAL = 1.day

    def self.update_movies_for_all_languages
        NowPlayingMovie.destroy_all

        tmdb_map = NowPlayingMovie.tmdb_map(:en)["results"]
        tmdb_map.each do |movie|
            Movie.create(id: movie["id"]) if Movie.exists?(movie["id"]) == false
            NowPlayingMovie.create(movie_id: movie["id"])
        end

        I18n.available_locales.each do |language_code|
            update_details_of_movies(language_code)
        end
    end

    private

    def self.update_details_of_movies(language_code)
        tmdb_map = NowPlayingMovie.tmdb_map(language_code)
        MovieDetailSet.create_or_update_basic_details_of_movies_from_json(tmdb_map, language_code)
    end

    def self.tmdb_map(language_code)
        HTTParty.get("https://api.themoviedb.org/3/movie/now_playing?api_key=#{Rails.application.credentials.tmdb[:api_key]}&language=#{language_code.to_s}&page=1")
    end

end