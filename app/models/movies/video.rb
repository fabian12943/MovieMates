class Movies::Video < ApplicationRecord
    self.table_name = "movie_videos"

    belongs_to :movie

    VALIDITY_PERIOD = 1.day

    @@valid_tmdb_fields = %w(name key site size offical published_at)

    def self.create_or_update_for_movie(movie)
        videos = Movies::Video.where(movie_id: movie.id)
        if videos.empty? || videos.minimum(:updated_at) < VALIDITY_PERIOD.ago
            videos.destroy_all
            Movies::Video.create_from_tmdb_request(movie)
        end
    end

    def self.create_from_tmdb_request(movie)
        tmdb_map = tmdb_map(movie.tmdb_id, movie.language)
        tmdb_map.each do |tmdb_video|
            video = Movies::Video.new(movie_id: movie.id)
            (valid_tmdb_fields).each do |valid_tmdb_field|
                video.send("#{valid_tmdb_field}=", tmdb_video[valid_tmdb_field])
            end
            video.video_type = tmdb_video["type"] # Column type is reserved for storing the class in case of inheritance in Active Record
            video.save
        end
    end

    def self.tmdb_map(tmdb_id, language)
        tmdb_map = HTTParty.get("https://api.themoviedb.org/3/movie/#{tmdb_id}/videos?language=#{language}&api_key=#{Rails.application.credentials.tmdb.api_key}")
        tmdb_map["results"]
    end

    def self.valid_tmdb_fields
        @@valid_tmdb_fields
    end

    def self.youtube_trailer 
        all.where(video_type: "Trailer", site: "YouTube").first
    end

end