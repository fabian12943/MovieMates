class ApplicationController < ActionController::Base
    around_action :set_locale

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

end
