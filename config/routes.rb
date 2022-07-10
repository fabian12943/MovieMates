Rails.application.routes.draw do
    scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
        root to: redirect('/movies')

        post 'sign_up', to: 'users#create'

        post 'sign_in', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'

        post 'users/confirmation', to: 'user_confirmations#create'
        get 'users/confirmation/confirm', to: 'user_confirmations#update'

        post 'password/reset', to: 'password_resets#create'
        get 'password/reset/edit', to: 'password_resets#edit'
        patch 'password/reset/edit', to: 'password_resets#update'

        resources :comments, only: [:destroy]

        scope :users do
            scope '/:username' do
                resources :seen_movies, module: :users
            end
        end

        scope :movies do
            get '/', to: 'movies#index', as: 'movies'
            get '/popular/carousel', to: 'movies#popular_movies_carousel', as: 'movie_carousel'
            get '/popular/scroller', to: 'movies#popular_movies_scroller', as: 'popular_movies_scroller'
            get '/now-playing/scroller', to: 'movies#now_playing_movies_scroller', as: 'now_playing_movies_scroller'
            get '/upcoming/scroller', to: 'movies#upcoming_movies_scroller', as: 'upcoming_movies_scroller'
            get '/top-rated/scroller', to: 'movies#top_rated_movies_scroller', as: 'top_rated_movies_scroller'
            scope '/:id' do
                get '/trailer', to: 'movies#trailer', as: 'movie_trailer'
                get '/images', to: 'movies#images', as: 'movie_images'
                get '/casts', to: 'movies#casts', as: 'movie_casts'
                get '/casts/:person_id/detailed_card', to: 'movies#detailed_cast_card', as: 'detailed_cast_card'
                get '/recommendations', to: 'movies#recommendations', as: 'movie_recommendations'
                get '/index_card', to: 'movies#index_movie_card', as: 'index_movie_card'
                get '/detailed_card', to: 'movies#detailed_movie_card', as: 'detailed_movie_card'
                get '/detailed_card_with_subtext', to: 'movies#detailed_movie_card_with_subtext', as: 'detailed_movie_card_with_subtext'
                get '/', to: 'movies#details', as: 'movie_details'
                post '/seen_unseen', to: 'movies#seen_or_unseen', as: 'movie_seen_unseen'
                resources :comments, module: :movies, as: 'movies_movie_comments', only: [:create]
                resources :user_ratings, module: :movies, as: 'movie_rating', only: [:create, :destroy]
            end
        end

        scope :people do
            get '/popular/scroller', to: 'people#popular_people_scroller', as: 'popular_people_scroller'
            scope '/:id' do
                get '/card', to: 'people#card', as: 'person_card'
                get '/most-famous-movies', to: 'people#most_famous_movies', as: 'person_most_famous_movies_scroller'
                get '/filmography', to: 'people#filmography', as: 'person_filmography'
                get '/news', to: 'people#news_articles', as: 'person_news'
                get '/', to: 'people#details', as: 'person_details'
                resources :comments, module: :people, as: 'people_person_comments', only: [:create]
            end
        end

        scope :search do
            get '/', to: 'search#results', as: 'search'
            get '/movie', to: "search#movie_results", as: 'movie_results'
            get '/person', to: "search#person_results", as: 'person_results'
        end

        get '/watchlists', to: 'watchlists#index'

    end
    
    get 'auth/:provider/callback', to: 'sessions#omniauth'

    if defined?(Sidekiq) && defined?(Sidekiq::Web)
        mount Sidekiq::Web => '/sidekiq'
    end

end
