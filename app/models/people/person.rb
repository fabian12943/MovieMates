class People::Person < ApplicationRecord
    after_destroy :destroy_associated_records_if_possible, prepend: true

    validates :tmdb_id, uniqueness: { scope: :language_iso_639_1 }
    alias_attribute :language, :language_iso_639_1

    # Dependant on tmdb_id only
    has_one :external_ids, class_name: "People::ExternalIdsSet", primary_key: :tmdb_id, foreign_key: :person_tmdb_id
    has_many :movie_credits, class_name: "People::MovieCredit", primary_key: :tmdb_id, foreign_key: :person_tmdb_id
    has_many :movies, class_name: "Movies::Movie", primary_key: :tmdb_id, foreign_key: :tmdb_id, through: :movie_credits

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

    def movie_credits
        People::MovieCredit.create_or_update_for_person(self)
        super
    end

    def movies
        People::MovieCredit.create_or_update_for_person(self)
        super
    end

    def external_ids
        People::ExternalIdsSet.create_or_update_for_person(self)
        super
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
        case gender
        when 0 # unspecified
            return "no_cast_image_unspecified_placeholder.svg"
        when 1 # female
            return "no_cast_image_female_placeholder.svg"
        when 2 # male
            return "no_cast_image_male_placeholder.svg"
        end
    end

    def to_param
        return nil unless persisted?
        [tmdb_id, name].join('-').parameterize
    end

    def age
        return nil if birthday.blank?
        date_from = birthday
        date_to = deathday.present? ? deathday : Time.now.utc.to_date
        date_to.year - date_from.year - ((date_to.month > date_from.month || (date_to.month == date_from.month && date_to.day >= date_from.day)) ? 0 : 1)
    end

    def gender_description
        case gender
        when 0
            "Keine Angabe"
        when 1
            "Weiblich"
        when 2
            "Männlich"
        end
    end

    private

    def destroy_associated_records_if_possible
        if People::Person.where(tmdb_id: tmdb_id).count == 0
            People::ExternalIdsSet.where(person_tmdb_id: tmdb_id).destroy_all
            People::MovieCredit.where(person_tmdb_id: tmdb_id).destroy_all
        end
    end

end