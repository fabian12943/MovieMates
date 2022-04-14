Rails.application.routes.draw do
    scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
        root to: redirect('/movies')

        scope :movies do
            get '/', to: 'movies#index', as: 'movies'
            get '/popular/carousel', to: 'movies#popular_movies_carousel', as: 'movie_carousel'
            get '/popular/scroller', to: 'movies#popular_movies_scroller', as: 'popular_movies_scroller'
            get '/now-playing/scroller', to: 'movies#now_playing_movies_scroller', as: 'now_playing_movies_scroller'
            get '/upcoming/scroller', to: 'movies#upcoming_movies_scroller', as: 'upcoming_movies_scroller'
            get '/top-rated/scroller', to: 'movies#top_rated_movies_scroller', as: 'top_rated_movies_scroller'
            get '/:id', to: 'movies#details', as: 'movie_details'
        end

        get '/watchlists', to: 'watchlists#index'

    end

    if defined?(Sidekiq) && defined?(Sidekiq::Web)
        mount Sidekiq::Web => '/sidekiq'
    end

end
