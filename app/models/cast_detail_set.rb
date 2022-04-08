class CastDetailSet < ApplicationRecord
    belongs_to :cast

    UPDATE_INTERVAL = 1.day

    def self.create_or_update(tmdb_id, language_code)
        cast_detail_set = CastDetailSet.find_by(cast_id: tmdb_id, language_code: language_code)
        if cast_detail_set.nil? || cast_detail_set.outdated_data?
            if cast_detail_set.nil?
                cast_detail_set = CastDetailSet.new
                cast_detail_set.cast_id = tmdb_id
                cast_detail_set.language_code = language_code
            end
            cast_detail_set.update
        end
    end

    def self.tmdb_map(tmdb_id, language_code)
        tmdb_map = Tmdb::Person.detail(tmdb_id, language: language_code)
        if tmdb_map["status_code"] == 34
            raise "The resource with tmdb id #{tmdb_id} could not be found."
        end
        tmdb_map
    end

    def update
        tmdb_map = CastDetailSet::tmdb_map(self.cast_id, self.language_code)
        (CastDetailSet.column_names - ['id', 'cast_id', 'language_code', 'created_at', 'updated_at']).each do |column_name|
            self.send("#{column_name}=", tmdb_map[column_name])
        end
        self.changed? ? self.save : self.touch
    end

    def outdated_data?
        self.updated_at < UPDATE_INTERVAL.ago
    end

    def self.create_several(tmdb_ids, language_code)
        threads = []
        tmdb_ids.each do |tmdb_id| 
            threads << Thread.new do
                Cast.create(id: tmdb_id) if Cast.exists?(tmdb_id) == false
                CastDetailSet.create_or_update(tmdb_id, language_code)
                ActiveRecord::Base.connection.close
            end
        end
        threads.each(&:join)
        I18n.locale = language_code # TODO: Temporary Fix: Locale get lost after threads are finished
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
