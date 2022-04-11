class CastDetailSet < ApplicationRecord
    belongs_to :cast

    UPDATE_INTERVAL = 1.day

    BASIC_ATTRIBUTES = ['name', 'profile_path', 'gender']

    def self.create_or_update_basic_details_of_cast_from_json(json, language_code)
        threads = []
        json.each do |cast_json|
            threads << Thread.new do
                cast_id = cast_json["id"]
                cast_detail_set = CastDetailSet.find_by(cast_id: cast_id, language_code: language_code)
                if cast_detail_set.nil? || cast_detail_set.outdated_data?
                    cast_detail_set = CastDetailSet.add_required_attributes(cast_id, language_code) if cast_detail_set.nil?
                    cast_detail_set.update_basic_details_of_cast_from_json(cast_json)
                end
                ActiveRecord::Base.connection.close
            end
        end
        threads.each(&:join)
        I18n.locale = language_code # TODO: Temporary Fix: Locale get lost after threads are finished
    end

    def outdated_data?
        self.updated_at < UPDATE_INTERVAL.ago
    end

    def self.add_required_attributes(cast_id, language_code)
        Cast.create(id: cast_id) if Cast.exists?(cast_id) == false
        cast_detail_set = CastDetailSet.new
        cast_detail_set.cast_id = cast_id
        cast_detail_set.language_code = language_code
        cast_detail_set
    end

    def update_basic_details_of_cast_from_json(json)
        (BASIC_ATTRIBUTES).each do |column_name|
            self.send("#{column_name}=", json[column_name])
        end
        self.complete = false
        self.changed? ? self.save : self.touch
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
