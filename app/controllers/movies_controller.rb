class MoviesController < ApplicationController

    before_action :set_movie, only: [:details]

    def details
        @country_code = "DE"
    end

    def popular_movies_carousel
        number_of_movies = 5
        movie_tmdb_ids = Movies::Popular.first(number_of_movies).pluck(:movie_tmdb_id)
        Movies::Movie.create_or_update_movies(movie_tmdb_ids, I18n.locale, true)
        movies = Movies::Popular.movies.where(language: I18n.locale).order(popularity: :desc).first(number_of_movies)
        render partial: "movies/index_partials/movie_carousel", locals: { movies: movies }
    end

    def popular_movies_scroller
        movies = Movies::Popular.movies.where(language: I18n.locale).order(popularity: :desc).first(20)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "popular" }
    end

    def now_playing_movies_scroller
        movies = Movies::NowPlaying.movies.where(language: I18n.locale).order(release_date: :desc).first(20)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "now-playing" }
    end

    def upcoming_movies_scroller
        movies = Movies::Upcoming.movies.where(language: I18n.locale).order(:release_date).first(20)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "upcoming" }
    end

    def top_rated_movies_scroller
        movies = Movies::TopRated.movies.where(language: I18n.locale).order(vote_average: :desc).first(20)
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
        begin
            Movies::Movie.create_or_update_movie(params[:id], I18n.locale)
            @movie = Movies::Movie.find_by(tmdb_id: params[:id], language: I18n.locale)
        rescue TmdbErrors::ResourceNotFoundError => e
            not_found
        end
    end

end
