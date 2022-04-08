class CreateOrUpdateMovieCastsJob
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(tmdb_id, language_code)
        MovieCastSet.create_or_update(tmdb_id, language_code)
    end

end