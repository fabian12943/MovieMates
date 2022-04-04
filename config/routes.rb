Rails.application.routes.draw do
    scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
        root to: 'home#index'
        get '/movies/:id', to: 'movies#details', as: 'movie_details'
    end
end
