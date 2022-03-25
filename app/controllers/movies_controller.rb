class MoviesController < ApplicationController

    before_action :set_movie, only: [:details]

    def details
        country_code = "DE"
        begin
            @movie.create_or_update_movie_information_if_necessary_for_language(I18n.locale, country_code)
        rescue
            @movie.destroy
            not_found
        end

        @movie_details = @movie.details.find_by(language_code: I18n.locale)
        @movie_releases = @movie.releases.find_by(country_code: country_code)
        @movie_keyword_set = @movie.keyword_set
        @movie_backdrop_set = @movie.backdrop_set
    end

    def create
        movie = Movie.new(movie_params)
        movie.save
    end

    private
    
    def movie_params
        params.permit(:id)
    end

    def set_movie
        create unless Movie.exists?(params[:id])
        @movie = Movie.find(params[:id])
    end

    def fetch(tmdb_id)
        movie = Movie.find_by(tmdb_id: tmdb_id, request_language: I18n.locale)
        if movie.nil?
            movie = create(tmdb_id)
        elsif movie.updated_at < (Movie::UPDATE_INTERVAL).ago
            movie = update(movie)
        end
        movie
    end

    def create(tmdb_id)
        movie = Movie.new
        movie.tmdb_id = request['id']
        movie.request_language = I18n.locale

        set_and_save_attributes_from_json_to(movie)
        movie 
    end

    def update(movie)
        set_and_save_attributes_from_json_to(movie)
        movie
    end

    private 

    def set_and_save_attributes_from_json_to(movie)
        response = Tmdb::Movie.detail(movie.tmdb_id, language: movie.request_language, include_image_language: "null,en", append_to_response: 'keywords,images,releases,trailers')
        not_found if response['success'] == false

        (Movie.column_names - ['id', 'tmdb_id', 'request_language']).each do |column_name|
            movie.send("#{column_name}=", response[column_name]) unless response[column_name].nil?
        end

        movie.save
    end

end
