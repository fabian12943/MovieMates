class UpdateTopRatedMoviesWorker
    include Sidekiq::Worker

    def perform
        TopRatedMovie.update_movies_for_all_languages
    end

end