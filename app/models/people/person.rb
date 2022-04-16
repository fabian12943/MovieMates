class People::Person < ApplicationRecord
    validates :tmdb_id, uniqueness: { scope: :language_iso_639_1 }
    alias_attribute :language, :language_iso_639_1

    VALIDITY_PERIOD = 1.day

    @@valid_tmdb_fields_complete = %w(name profile_path gender adult also_known_as biography
                                    birthday deathday homepage imdb_id known_for_department
                                    place_of_birth popularity)

    @@valid_tmdb_fields_basic = %w(name profile_path gender)

    def self.create_or_update_person(tmdb_id, language, complete = true)
        person = People::Person.find_by(tmdb_id: tmdb_id, language: language)
        if person.nil? || person.needs_update?(completion_required = complete)
            person = People::Person.new(tmdb_id: tmdb_id, language: language) if person.nil?
            person.update_from_tmdb_request(complete)
        end
    end

    def self.create_or_update_people_from_tmdb_map(people_tmdb_map, language, complete = false)
        threads = []
        people_tmdb_map.each do |person_tmdb_map|
            threads << Thread.new do
                tmdb_id = person_tmdb_map["id"]
                person = People::Person.find_by(tmdb_id: tmdb_id, language: language)
                if person.nil? || person.needs_update?(completion_required = complete)
                    person = People::Person.new(tmdb_id: tmdb_id, language: language) if person.nil?
                    person.update_from_tmdb_json(person_tmdb_map, complete)
                end
                ActiveRecord::Base.connection.close
            end
        end
        threads.each(&:join)
        I18n.locale = language # TODO: Temporary Fix: Locale get lost after threads are finished
    end

    def needs_update?(completion_required)
        self.updated_at < VALIDITY_PERIOD.ago || (completion_required && self.complete? == false)
    end

    def update_from_tmdb_request(complete)
        tmdb_map = People::Person.tmdb_map(self.tmdb_id, self.language)
        self.update_from_tmdb_json(tmdb_map, complete)
    end

    def update_from_tmdb_json(tmdb_json, complete)
        (complete ? People::Person.valid_tmdb_fields_complete : People::Person.valid_tmdb_fields_basic).each do |valid_tmdb_field|
            self.send("#{valid_tmdb_field}=", tmdb_json[valid_tmdb_field])
        end
        self.complete = true if complete
        self.changed? ? self.save : self.touch
    end

    def self.tmdb_map(tmdb_id, language)
        tmdb_map = Tmdb::Person.detail(tmdb_id, language: language)
        if tmdb_map["status_code"] == 34
            raise TmdbErrors::ResourceNotFoundError.new("The person with tmdb id #{tmdb_id} could not be found.")
        end
        tmdb_map
    end

    def self.valid_tmdb_fields_complete
        @@valid_tmdb_fields_complete
    end

    def self.valid_tmdb_fields_basic
        @@valid_tmdb_fields_basic
    end

    def picture_path(image_size = "original")
        return nil if self.profile_path.blank?
        Tmdb::Configuration.new.secure_base_url + "#{image_size}" + self.profile_path
    end

    def picture_placeholder
        case self.gender
        when 0 # unspecified
            return "no_cast_image_unspecified_placeholder.svg"
        when 1 # female
            return "no_cast_image_female_placeholder.svg"
        when 2 # male
            return "no_cast_image_male_placeholder.svg"
        end
    end

end