class MoviesController < ApplicationController

    def details
        @movie = Tmdb::Movie.detail(params[:id], language: 'de') # TODO: change to user's locale later
        not_found if @movie['success'] == false && @movie['status_message'] == "The resource you requested could not be found."
        
        @movie_backdrops = Tmdb::Movie.images(params[:id])['backdrops']
        @movie_keywords = Tmdb::Movie.keywords(params[:id])
        @movie_releases = Tmdb::Movie.releases(params[:id])
        @movie_trailers = Tmdb::Movie.trailers(params[:id], language: 'de')

        @configuration = Tmdb::Configuration.new
    end

end
