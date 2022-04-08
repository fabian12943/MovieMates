class Movie < ApplicationRecord
    has_many :details, class_name: "MovieDetailSet", foreign_key: "movie_id", dependent: :destroy
    has_one :keyword_set, class_name: "MovieKeywordSet", foreign_key: "movie_id", dependent: :destroy
    has_many :releases, class_name: "MovieRelease", foreign_key: "movie_id", dependent: :destroy
    has_one :backdrop_set, class_name: "MovieBackdropSet", foreign_key: "movie_id", dependent: :destroy
    has_many :recommendation_sets, class_name: "MovieRecommendationSet", foreign_key: "movie_id", dependent: :destroy
    has_many :cast_sets, class_name: "MovieCastSet", foreign_key: "movie_id", dependent: :destroy

    def create_or_update_movie_information_if_necessary_for_language(language_code, country_code)
        # Perform immediately
        MovieDetailSet.create_or_update(self.id, language_code)
        MovieKeywordSet.create_or_update(self.id)
        MovieRelease.create_or_update(self.id, country_code)
        MovieBackdropSet.create_or_update(self.id)

        # Perform as background job
        CreateOrUpdateMovieCastsJob.perform_async(self.id.to_s, language_code.to_s)
        CreateOrUpdateMovieRecommendationsJob.perform_async(self.id.to_s, language_code.to_s)
    end
    
end
