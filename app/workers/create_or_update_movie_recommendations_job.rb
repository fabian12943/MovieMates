class CreateOrUpdateMovieRecommendationsJob
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(tmdb_id, language_code)
        MovieRecommendationSet.create_or_update(tmdb_id, language_code)
    end

end