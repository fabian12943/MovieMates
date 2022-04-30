class Search::Movie

    def initialize(query, locale)
        @query = query
        @locale = locale
        @tmdb_map = tmdb_map()
    end

    def total_results
        @tmdb_map["total_results"]
    end

    def total_pages
        @tmdb_map["total_pages"]
    end

    def movies(page)
        @tmdb_map = tmdb_map(page)
        create_or_update_movies(@tmdb_map)
        tmdb_ids = tdmb_ids()
        Movies::Movie.where(tmdb_id: tmdb_ids, language: @locale).sort_by {|p| tmdb_ids.index(p.tmdb_id) }
    end

    def tdmb_ids
        @tmdb_map["results"].map { |movie| movie["id"] }
    end

    private 

    def tmdb_map(page = 1)
        ascii_query = @query.parameterize(separator: " ")
        include_adult_results = false
        HTTParty.get("https://api.themoviedb.org/3/search/movie?query=#{ascii_query}&language=#{I18n.locale}&page=#{page}&include_adult=#{include_adult_results}&api_key=#{Rails.application.credentials.tmdb.api_key}")
    end

    def create_or_update_movies(tmdb_map)
        Movies::Movie.create_or_update_movies_from_tmdb_map(tmdb_map["results"], @locale)
    end
end