class PeopleController < ApplicationController

    before_action :set_person, only: [:details]

    def details
    end

    private
    
    def person_params
        params.permit(:id, :locale)
    end

    def set_person
        tmdb_id = person_params[:id]
        if tmdb_id.to_i == 0
            not_found
        end
        begin
            People::Person.create_or_update_person(tmdb_id, I18n.locale)
            @person = People::Person.find_by(tmdb_id: tmdb_id, language: I18n.locale)
        rescue TmdbErrors::ResourceNotFoundError => e
            not_found
        end
    end

end
