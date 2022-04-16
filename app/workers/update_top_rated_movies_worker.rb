class UpdateTopRatedMoviesWorker
    include Sidekiq::Worker

    def perform
        Movies::TopRated.update
    end

end