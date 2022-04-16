class UpdateUpcomingMoviesWorker
    include Sidekiq::Worker

    def perform
        Movies::Upcoming.update
    end

end