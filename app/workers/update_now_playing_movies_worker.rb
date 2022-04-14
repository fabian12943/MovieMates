class UpdateNowPlayingMoviesWorker
    include Sidekiq::Worker

    def perform
        NowPlayingMovie.update_movies_for_all_languages
    end

end