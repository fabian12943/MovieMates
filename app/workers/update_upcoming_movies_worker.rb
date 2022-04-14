class UpdateUpcomingMoviesWorker
    include Sidekiq::Worker

    def perform
        UpcomingMovie.update_movies_for_all_languages
    end

end