require "addressable/uri"

class People::NewsArticle < ApplicationRecord
    self.table_name = "person_news_articles"

    belongs_to :person

    VALIDITY_PERIOD = 1.day

    @@valid_gnews_fields = %w(title description url image publishedAt source)

    def self.create_or_update_for_person(person)
        news_articles = People::NewsArticle.where(person_id: person.id)
        if news_articles.empty? || news_articles.minimum(:updated_at) < VALIDITY_PERIOD.ago
            news_articles.destroy_all
            People::NewsArticle.create_from_gnews_request(person)
        end
    end

    def self.create_from_gnews_request(person)
        gnews_map = gnews_map(person)
        return if gnews_map.blank?
        transaction do
            gnews_map.each do |gnews_news_article|
                news_article = People::NewsArticle.new(person_id: person.id)
                (valid_gnews_fields).each do |valid_gnews_field|
                    news_article.send("#{valid_gnews_field}=", gnews_news_article[valid_gnews_field])
                end
                news_article.save
            end
        end
    end

    def self.valid_gnews_fields
        @@valid_gnews_fields
    end

    def self.gnews_map(person)
        normalized_name = Addressable::URI.parse(person.name).normalize.to_s
        uri = "https://gnews.io/api/v4/search?q=#{normalized_name}&lang=#{person.language}&in=title,description}&token=#{Rails.application.credentials.gnews.api_key}"
        gnews_map = HTTParty.get(uri).parsed_response["articles"]
    end

    def self.distinct_content
        all.select("DISTINCT ON (description) *")
    end

end