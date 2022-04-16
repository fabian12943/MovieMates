class Movies::Movie < ApplicationRecord
    after_destroy :destroy_associated_records_if_possible, prepend: true
    
    validates :tmdb_id, uniqueness: { scope: :language_iso_639_1 }
    alias_attribute :language, :language_iso_639_1

    # Dependant on tmdb_id only
    has_many :backdrops, class_name: "Movies::Backdrop", primary_key: :tmdb_id, foreign_key: :movie_tmdb_id
    has_many :keywords, class_name: "Movies::Keyword", primary_key: :tmdb_id, foreign_key: :movie_tmdb_id
    has_many :releases, class_name: "Movies::Release", primary_key: :tmdb_id, foreign_key: :movie_tmdb_id
    has_many :recommendations, class_name: "Movies::Recommendation", primary_key: :tmdb_id, foreign_key: :movie_tmdb_id
    has_many :recommended_movies, class_name: "Movies::Movie", primary_key: :tmdb_id, foreign_key: :tmdb_id, through: :recommendations
    has_many :casts, class_name: "Movies::Cast", primary_key: :tmdb_id, foreign_key: :movie_tmdb_id
    has_many :casted_people, class_name: "People::Person", primary_key: :tmdb_id, foreign_key: :tmdb_id, through: :casts, source: :person

    # Dependant on tmdb_id and language
    has_many :videos, class_name: "Movies::Video", foreign_key: :movie_id, dependent: :destroy

    VALIDITY_PERIOD = 1.day

    @@valid_tmdb_fields_complete = %w(title overview adult backdrop_path belongs_to_collection budget genres 
                                    homepage imdb_id original_language original_title popularity poster_path 
                                    production_companies production_countries release_date revenue runtime 
                                    spoken_languages status tagline video vote_average vote_count)

    @@valid_tmdb_fields_basic = %w(title overview popularity poster_path release_date vote_average vote_count)

    def self.create_or_update_movie(tmdb_id, language, complete = true)
        movie = Movies::Movie.find_by(tmdb_id: tmdb_id, language: language)
        if movie.nil? || movie.needs_update?(completion_required = complete)
            movie = Movies::Movie.new(tmdb_id: tmdb_id, language: language) if movie.nil?
            movie.update_from_tmdb_request(complete)
        end
    end

    def self.create_or_update_movies(tmdb_ids, language, complete = true)
        tmdb_ids.each do |tmdb_id|
            Movies::Movie.create_or_update_movie(tmdb_id, language, complete)
        end
    end

    def self.create_or_update_movies_from_tmdb_map(movies_tmdb_map, language, complete = false)
        threads = []
        movies_tmdb_map.each do |movie_tmdb_map|
            threads << Thread.new do
                tmdb_id = movie_tmdb_map["id"]
                movie = Movies::Movie.find_by(tmdb_id: tmdb_id, language: language)
                if movie.nil? || movie.needs_update?(completion_required = complete)
                    movie = Movies::Movie.new(tmdb_id: tmdb_id, language: language) if movie.nil?
                    movie.update_from_tmdb_json(movie_tmdb_map, complete)
                end
                ActiveRecord::Base.connection.close
            end
        end
        threads.each(&:join)
        I18n.locale = language # TODO: Temporary Fix: Locale get lost after threads are finished
    end

    def self.tmdb_map(tmdb_id, language)
        tmdb_map = Tmdb::Movie.detail(tmdb_id, language: language)
        if tmdb_map["status_code"] == 34
            raise TmdbErrors::ResourceNotFoundError.new("The movie with tmdb id #{tmdb_id} could not be found.")
        end
        tmdb_map
    end

    def self.valid_tmdb_fields_complete
        @@valid_tmdb_fields_complete
    end

    def self.valid_tmdb_fields_basic
        @@valid_tmdb_fields_basic
    end

    def update_from_tmdb_request(complete)
        tmdb_map = Movies::Movie.tmdb_map(self.tmdb_id, self.language)
        self.update_from_tmdb_json(tmdb_map, complete)
    end

    def update_from_tmdb_json(tmdb_json, complete)
        (complete ? Movies::Movie.valid_tmdb_fields_complete : Movies::Movie.valid_tmdb_fields_basic).each do |valid_tmdb_field|
            self.send("#{valid_tmdb_field}=", tmdb_json[valid_tmdb_field])
        end
        self.complete = true if complete
        self.changed? ? self.save : self.touch
    end

    def needs_update?(completion_required)
        self.updated_at < VALIDITY_PERIOD.ago || (completion_required && self.complete? == false)
    end

    def recommended_movies
        Movies::Recommendation.create_or_update_for_movie(self)
        super
    end

    def recommendations
        Movies::Recommendation.create_or_update_for_movie(self)
        super
    end

    def casted_people
        Movies::Cast.create_or_update_for_movie(self)
        super
    end

    def casts
        Movies::Cast.create_or_update_for_movie(self)
        super
    end

    def backdrops
        Movies::Backdrop.create_or_update_for_movie(self)
        super 
    end

    def keywords
        Movies::Keyword.create_or_update_for_movie(self)
        super
    end

    def videos
        Movies::Video.create_or_update_for_movie(self)
        super
    end

    def releases(country)
        Movies::Release.create_or_update_for_movie(self, country)
        Movies::Release.where(movie_tmdb_id: tmdb_id, country: country)
    end

    def picture_path(image_size = "original")
        return nil if self.poster_path.blank?
        Tmdb::Configuration.new.secure_base_url + "#{image_size}" + self.poster_path
    end

    def picture_placeholder
        "no_image_placeholder.svg"
    end

    def to_param
        return nil unless persisted?
        [tmdb_id, title].join('-').parameterize
    end

    def rating_classification
        return "no-votes" if self.vote_count == 0
        case self.vote_average
        when 0...5
            "bad"
        when 5...7
            "average"
        when 7...8
            "good"
        when 8..10
            "excellent"
        end
    end

    def release_year
        release_date.year
    end

    private

    def destroy_associated_records_if_possible
        if Movies::Movie.where(tmdb_id: tmdb_id).count == 0
            Movies::Backdrop.where(movie_tmdb_id: tmdb_id).destroy_all
            Movies::Keyword.where(movie_tmdb_id: tmdb_id).destroy_all
            Movies::Release.where(movie_tmdb_id: tmdb_id).destroy_all
            Movies::Recommendation.where(movie_tmdb_id: tmdb_id).destroy_all
            Movies::Cast.where(movie_tmdb_id: tmdb_id).destroy_all
        end
    end

end