class MoviesController < ApplicationController

    before_action :set_movie, only: [:details]

    def details
        country_code = "DE"
        begin
            @movie.create_or_update_movie_information_if_necessary_for_language(I18n.locale, country_code)
        rescue TmdbErrors::ResourceNotFoundError => e
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

end
