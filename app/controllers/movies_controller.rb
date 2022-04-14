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

    def popular_movies_carousel
        movie_ids = PopularMovie.pluck(:movie_id)
        MovieDetailSet.create_or_update_all_details_of_movies(tmdb_ids = movie_ids, language_code = I18n.locale)
        MovieBackdropSet.create_or_update_several(tmdb_ids = movie_ids)
        movie_details = MovieDetailSet.where(movie_id: movie_ids, language_code: I18n.locale).order(popularity: :desc).first(5)
        movie_backdrops = MovieBackdropSet.where(movie_id: movie_ids)
        render partial: "movies/index_partials/movie_carousel", locals: { movie_details: movie_details, movie_backdrops: movie_backdrops }
    end

    def popular_movies_scroller
        movies = MovieDetailSet.where(movie_id: PopularMovie.pluck(:movie_id), language_code: I18n.locale).order(popularity: :desc)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "popular" }
    end

    def now_playing_movies_scroller
        movies = MovieDetailSet.where(movie_id: NowPlayingMovie.pluck(:movie_id), language_code: I18n.locale).order(release_date: :desc)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "now-playing" }
    end

    def upcoming_movies_scroller
        movies = MovieDetailSet.where(movie_id: UpcomingMovie.pluck(:movie_id), language_code: I18n.locale).order(:release_date)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "upcoming" }
    end

    def top_rated_movies_scroller
        movies =  MovieDetailSet.where(movie_id: TopRatedMovie.pluck(:movie_id), language_code: I18n.locale).order(vote_average: :desc)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "top-rated" }
    end

    private
    
    def movie_params
        params.permit(:id)
    end

    def set_movie
        if params[:id].to_i == 0
            not_found
        end
        create unless Movie.exists?(params[:id])
        @movie = Movie.find(params[:id])
    end

end
