class Movie < ApplicationRecord
    has_many :details, class_name: "MovieDetailSet", foreign_key: "movie_id", dependent: :destroy
    has_one :keyword_set, class_name: "MovieKeywordSet", foreign_key: "movie_id", dependent: :destroy
    has_many :releases, class_name: "MovieRelease", foreign_key: "movie_id", dependent: :destroy
    has_one :backdrop_set, class_name: "MovieBackdropSet", foreign_key: "movie_id", dependent: :destroy

    def create_or_update_movie_information_if_necessary_for_language(language_code, country_code)
        methods = [ 
                    MovieDetailSet.create_or_update(self.id, language_code),
                    MovieKeywordSet.create_or_update(self.id),
                    MovieRelease.create_or_update(self.id, country_code),
                    MovieBackdropSet.create_or_update(self.id)]

        methods.each do |method|
            method
        end
    end
    
end
