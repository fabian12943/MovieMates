class ApplicationController < ActionController::Base
    around_action :set_locale
    before_action :load_footer_resources, :set_country
    helper_method :current_user, :user_logged_in?

    def current_user
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def user_logged_in?
        !!current_user
    end

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end

    private 

    def set_locale(&action)
        I18n.with_locale(extract_locale || I18n.default_locale, &action)
    end

    def extract_locale
        parsed_locale = params[:locale] || http_accept_language.compatible_language_from(I18n.available_locales)
    end

    def default_url_options
        { locale: I18n.locale }
    end

    def set_country
        session[:country] = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/[A-Z]{2}/).first
    end

    def load_footer_resources
        amount_links = 10
        @popular_movies = Movies::Popular.movies.where(language: I18n.locale).order(popularity: :desc).first(amount_links)
        @now_playing_movies = Movies::NowPlaying.movies.where(language: I18n.locale).order(release_date: :desc).first(amount_links)
        @upcoming_movies = Movies::Upcoming.movies.where(language: I18n.locale).order(:release_date).first(amount_links)
        @popular_people = People::Popular.people.where(language: I18n.locale).order(popularity: :desc).first(amount_links)
    end

end
