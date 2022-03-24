Rails.application.routes.draw do
    root to: 'home#index'
    
    get '/movies/:id', to: 'movies#details'
end
