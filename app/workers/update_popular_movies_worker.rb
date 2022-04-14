class UpdatePopularMoviesWorker
    include Sidekiq::Worker

    def perform
        PopularMovie.update_movies_for_all_languages
    end

end