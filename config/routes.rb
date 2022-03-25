Rails.application.routes.draw do
    scope "(:locale)", locale: /en|de|es|ar/ do
        root to: 'home#index'
        get '/movies/:id', to: 'movies#details', as: 'movie_details'
    end
end
