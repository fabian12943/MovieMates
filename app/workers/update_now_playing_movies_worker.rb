class UpdateNowPlayingMoviesWorker
    include Sidekiq::Worker

    def perform
        Movies::NowPlaying.update
    end

end