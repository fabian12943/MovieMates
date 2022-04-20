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
            get '/:id/trailer', to: 'movies#trailer', as: 'movie_trailer'
            get '/:id/images', to: 'movies#images', as: 'movie_images'
            get '/:id/casts', to: 'movies#casts', as: 'movie_casts'
            get '/:id/casts/:person_id/detailed_card', to: 'movies#detailed_cast_card', as: 'detailed_cast_card'
            get '/:id/recommendations', to: 'movies#recommendations', as: 'movie_recommendations'
            get '/:id/index_card', to: 'movies#index_movie_card', as: 'index_movie_card'
            get '/:id/detailed_card', to: 'movies#detailed_movie_card', as: 'detailed_movie_card'
            get '/:id', to: 'movies#details', as: 'movie_details'
        end

        scope :people do
            get '/popular/scroller', to: 'people#popular_people_scroller', as: 'popular_people_scroller'
            get '/:id/card', to: 'people#card', as: 'person_card'
            get '/:id/filmography', to: 'people#filmography', as: 'person_filmography'
            get '/:id', to: 'people#details', as: 'person_details'
        end

        get '/watchlists', to: 'watchlists#index'

    end

    if defined?(Sidekiq) && defined?(Sidekiq::Web)
        mount Sidekiq::Web => '/sidekiq'
    end

end
