class ApplicationController < ActionController::Base
    around_action :set_locale
    before_action :load_footer_resources

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end

    private 

    def set_locale(&action)
        I18n.with_locale(params[:locale] || I18n.default_locale, &action)
    end

    def default_url_options
        { locale: I18n.locale }
    end

    def load_footer_resources
        amount_links = 10
        @popular_movies = Movies::Popular.movies.where(language: I18n.locale).order(popularity: :desc).first(amount_links)
        @now_playing_movies = Movies::NowPlaying.movies.where(language: I18n.locale).order(release_date: :desc).first(amount_links)
        @upcoming_movies = Movies::Upcoming.movies.where(language: I18n.locale).order(:release_date).first(amount_links)
        @top_rated_movies = Movies::TopRated.movies.where(language: I18n.locale).order(vote_average: :desc).first(amount_links)
    end

end
