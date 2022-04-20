class PeopleController < ApplicationController

    before_action :set_person, only: [:details, :card, :most_famous_movies, :filmography]

    def details
        People::MovieCredit.create_or_update_for_person(@person)
        People::ExternalIdsSet.create_or_update_for_person(@person)
    end

    def popular_people_scroller
        people = People::Popular.people.where(language: I18n.locale).order(popularity: :desc).first(40)
        render partial: "people/details_partials/people_scroller", locals: { people: people, type: "popular" }
    end

    def card
        render partial: "people/details_partials/person_card", locals: { person: @person }
    end

    def most_famous_movies
        movie_credits = @person.movie_credits.order(:order)
        render partial: "people/details_partials/movies_scroller", locals: { movie_credits: movie_credits }
    end

    def filmography
        render partial: "people/details_partials/filmography", locals: { person: @person }
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
