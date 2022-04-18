class People::Popular < ApplicationRecord
    self.table_name = "popular_people"

    has_one :person, primary_key: :person_tmdb_id, foreign_key: :tmdb_id

    NUMBER_PEOPLE = 40 # Best in steps of 20, since each request page has 20 entries

    def self.update
        People::Popular.destroy_all

        updated_people = 0
        page = 1
        while updated_people < NUMBER_PEOPLE
            tmdb_map = tmdb_map(page)
            tmdb_map.each do |person|
                break if updated_people >= NUMBER_PEOPLE
                People::Popular.create(person_tmdb_id: person["id"])
                updated_people += 1
            end
            page += 1
        end

        create_or_update_people_for_available_locales
    end

    def self.create_or_update_people_for_available_locales
        I18n.available_locales.each do |language_code|
            updated_people = 0
            page = 1
            while updated_people < NUMBER_PEOPLE
                tmdb_map = tmdb_map(page, language_code.to_s)
                People::Person.create_or_update_people_from_tmdb_map(tmdb_map, language_code.to_s, false)
                updated_people += tmdb_map.size
                page += 1
            end
        end
    end

    def self.tmdb_map(page, language = "en")
        tmdb_map = HTTParty.get("https://api.themoviedb.org/3/person/popular?language=#{language}&page=#{page}&api_key=#{Rails.application.credentials.tmdb[:api_key]}")
        tmdb_map["results"]
    end

    def self.people
        People::Person.where(tmdb_id: all.pluck(:person_tmdb_id))
    end
    
end