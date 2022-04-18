class People::ExternalIdsSet < ApplicationRecord
    self.table_name = "person_external_ids_sets"

    has_many :people, primary_key: :person_tmdb_id, foreign_key: :tmdb_id

    VALIDITY_PERIOD = 1.day

    @@valid_tmdb_fields = %w(imdb_id facebook_id twitter_id instagram_id)

    def self.create_or_update_for_person(person)
        external_ids_set = People::ExternalIdsSet.where(person_tmdb_id: person.tmdb_id)
        if external_ids_set.empty? || external_ids_set.minimum(:updated_at) < VALIDITY_PERIOD.ago
            external_ids_set.destroy_all
            People::ExternalIdsSet.create_from_tmdb_request(person)
        end
    end

    def self.create_from_tmdb_request(person)
        tmdb_map = tmdb_map(person.tmdb_id)
        external_ids_set = People::ExternalIdsSet.new(person_tmdb_id: person.tmdb_id)
        (valid_tmdb_fields).each do |valid_tmdb_field|
            external_ids_set.send("#{valid_tmdb_field}=", tmdb_map[valid_tmdb_field])
        end
        external_ids_set.save
    end

    def self.valid_tmdb_fields
        @@valid_tmdb_fields
    end

    def self.tmdb_map(tmdb_id)
        tmdb_map = HTTParty.get("https://api.themoviedb.org/3/person/#{tmdb_id}/external_ids?api_key=#{Rails.application.credentials.tmdb.api_key}")
    end

    def instagram_url
        return nil unless instagram_id
        "https://instagram.com/#{instagram_id}"
    end
    
    def twitter_url
        return nil unless twitter_id
        "https://twitter.com/#{twitter_id}"
    end
    
    def facebook_url
        return nil unless facebook_id
        "https://facebook.com/#{facebook_id}"
    end

    def imdb_url
        return nil unless imdb_id
        "https://www.imdb.com/name/#{imdb_id}/"
    end

    def any_ids?
        imdb_id.present? || facebook_id.present? || twitter_id.present? || instagram_id.present?
    end

end