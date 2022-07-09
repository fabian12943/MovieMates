class MoviesController < ApplicationController

    before_action :set_movie, only: [:details, :trailer, :images, :casts, :recommendations, :detailed_movie_card, :detailed_movie_card_with_subtext, :index_movie_card, :detailed_cast_card, :seen_or_unseen]
    before_action :require_login, only: [:seen]

    def trailer
        render partial: "movies/details_partials/trailer", locals: { movie: @movie }
    end

    def images
        render partial: "movies/details_partials/images", locals: { movie: @movie }
    end

    def casts
        render partial: "movies/details_partials/casts", locals: { movie: @movie }
    end

    def detailed_cast_card
        cast = Movies::Cast.find_by(movie_tmdb_id: movie_params[:id], person_tmdb_id: movie_params[:person_id])
        not_found if cast.nil?
        render partial: "movies/details_partials/detailed_cast_card", locals: { movie: @movie, cast: cast }
    end

    def recommendations
        render partial: "movies/details_partials/recommendations", locals: { movie: @movie }
    end

    def detailed_movie_card
        render partial: "movies/details_partials/detailed_movie_card", locals: { movie: @movie }
    end

    def detailed_movie_card_with_subtext
        subtext = movie_params[:subtext]
        render partial: "movies/details_partials/detailed_movie_card", locals: { movie: @movie, subtext: subtext }
    end

    def index_movie_card
        render partial: "movies/index_partials/index_movie_card", locals: { movie: @movie }
    end

    def popular_movies_carousel
        number_of_movies = 5
        movie_tmdb_ids = Movies::Popular.first(number_of_movies).pluck(:movie_tmdb_id)
        Movies::Movie.create_or_update_movies(movie_tmdb_ids, I18n.locale, true)
        movies = Movies::Popular.movies.where(language: I18n.locale).order(popularity: :desc).first(number_of_movies)
        render partial: "movies/index_partials/movie_carousel", locals: { movies: movies }
    end

    def popular_movies_scroller
        movies = Movies::Popular.movies.where(language: I18n.locale).order(popularity: :desc).first(40)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "popular" }
    end

    def now_playing_movies_scroller
        movies = Movies::NowPlaying.movies.where(language: I18n.locale).order(release_date: :desc).first(40)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "now-playing" }
    end

    def upcoming_movies_scroller
        movies = Movies::Upcoming.movies.where(language: I18n.locale).order(:release_date).first(40)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "upcoming" }
    end

    def top_rated_movies_scroller
        movies = Movies::TopRated.movies.where(language: I18n.locale).order(vote_average: :desc).first(40)
        render partial: "movies/index_partials/index_movies_scroller", locals: { movies: movies, type: "top-rated" }
    end

    def seen_or_unseen
        if SeenMovie.where(user_id: current_user.id, movie_tmdb_id: @movie.tmdb_id).exists?
            SeenMovie.where(user_id: current_user.id, movie_tmdb_id: @movie.tmdb_id).destroy_all
        else
            SeenMovie.create(user_id: current_user.id, movie_tmdb_id: @movie.tmdb_id)
        end
        respond_to do |format|
            format.turbo_stream {
                render turbo_stream: turbo_stream.replace_all(".user_actions", partial: "movies/details_partials/user_actions");
            }
        end
    end

    private
    
    def movie_params
        params.permit(:id, :person_id, :locale, :subtext)
    end

    def set_movie
        tmdb_id = movie_params[:id]
        if tmdb_id.to_i == 0
            not_found
        end
        begin
            Movies::Movie.create_or_update_movie(tmdb_id, I18n.locale)
            @movie = Movies::Movie.find_by(tmdb_id: tmdb_id, language: I18n.locale)
        rescue TmdbErrors::ResourceNotFoundError => e
            not_found
        end
    end

end
