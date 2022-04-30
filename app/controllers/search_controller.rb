class SearchController < ApplicationController
    before_action :set_results, only: [:results, :movie_results, :person_results]

    def results
        redirect_to movie_results_path(query: @query, page: 1) and return
    end

    def movie_results
        @movies = @movie_search.movies(search_params[:page])
    end

    def person_results
        @people = @person_search.people(search_params[:page])
    end

    private 

    def search_params
        params.permit(:query, :locale, :page)
    end

    def set_results
        @query = search_params[:query]
        @movie_search = Search::Movie.new(@query, I18n.locale)
        @person_search = Search::Person.new(@query, I18n.locale)
    end
end
