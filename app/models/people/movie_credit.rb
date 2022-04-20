class People::MovieCredit < ApplicationRecord
    self.table_name = "person_movie_credits"

    has_one :person, class_name: "People::Person", primary_key: :person_tmdb_id, foreign_key: :tmdb_id
    has_many :movies, class_name: "Movies::Movie", primary_key: :movie_tmdb_id, foreign_key: :tmdb_id

    VALIDITY_PERIOD = 1.day

    @@valid_tmdb_fields = %w(character order release_date)

    def self.create_or_update_for_person(person)
        movie_credits = People::MovieCredit.where(person_tmdb_id: person.tmdb_id)
        if movie_credits.empty? || movie_credits.minimum(:updated_at) < VALIDITY_PERIOD.ago
            movie_credits.destroy_all
            People::MovieCredit.create_from_tmdb_request(person)
        end

        create_or_update_movie_credits_of_person(person)
    end

    def self.create_from_tmdb_request(person)
        tmdb_map = tmdb_map(person.tmdb_id, person.language)
        tmdb_map.each do |tmdb_movie_credit|
            movie_credit = People::MovieCredit.new(person_tmdb_id: person.tmdb_id, movie_tmdb_id: tmdb_movie_credit["id"])
            (valid_tmdb_fields).each do |valid_tmdb_field|
                movie_credit.send("#{valid_tmdb_field}=", tmdb_movie_credit[valid_tmdb_field])
            end
            movie_credit.voice = true if movie_credit.character.present? && movie_credit.character.include?("voice")
            movie_credit.save if movie_credit.release_date.present?
        end
    end

    def self.create_or_update_movie_credits_of_person(person)
        tmdb_map = tmdb_map(person.tmdb_id, person.language)
        Movies::Movie.create_or_update_movies_from_tmdb_map(tmdb_map, person.language, false)
    end

    def self.valid_tmdb_fields
        @@valid_tmdb_fields
    end

    def self.tmdb_map(tmdb_id, language)
        tmdb_map = HTTParty.get("https://api.themoviedb.org/3/person/#{tmdb_id}/movie_credits?language=#{language}&api_key=#{Rails.application.credentials.tmdb.api_key}")
        tmdb_map["cast"]
    end

    def self.years_with_movies
        all.map { |movie_credit| movie_credit.release_date.year if movie_credit.release_date.present? }.compact.uniq.sort.reverse
    end

    def self.by_years
        credits = {}
        all.years_with_movies.each do |year|
            movie_credits = all.where('extract(year from release_date) = ?', year)
            credits[year] = movie_credits
        end
        credits
    end
    
    def character_translated
        self[:character].gsub(/\(voice\)/, '(Stimme)')
                        .gsub(/\(uncredited\)/, '')
                        .gsub(/\(archive footage\)/, '')
                        .gsub(/Himself|Herself|Self/, 'Sich selbst')
                        
        # "#{self[:character]}#{" (Stimme)" if self[:voice]}"
        # movie_credit.character.gsub(/\([^()]*\)/, '') # Remove parenthesis and its content
    end

end