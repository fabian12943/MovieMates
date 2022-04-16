class UpdatePopularMoviesWorker
    include Sidekiq::Worker

    def perform
        Movies::Popular.update
    end

end