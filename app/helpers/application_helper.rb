module ApplicationHelper
    include Pagy::Frontend

    def duration_hours_minutes_format(total_minutes)
        hours = total_minutes / 60
        minutes = (total_minutes) % 60
        "#{hours}h #{minutes}min"
    end

    def tmdb_image_url(image_path, image_size = 'original')
        "#{Tmdb::Configuration.new.secure_base_url}#{image_size}#{image_path}"
    end

    def full_language_name_in_locale(language_code, locale = I18n.locale)
        I18nData.languages(locale)[language_code.upcase].titleize  
    end

    def date_in_locale_format(date, locale = I18n.locale)
        I18n.l(date, format: :long, locale: locale)
    end

    def picture(resource, image_size)
        if resource.respond_to?(:picture_path) == false || resource.picture_path.nil?
            inline_svg_tag resource.respond_to?(:picture_placeholder) ? resource.picture_placeholder : "no_image_placeholder", class: "img no-image-placeholder img-fluid", loading: "lazy"
        else
            image_tag resource.picture_path(image_size), class: "img-fluid", loading: "lazy"
        end
    end

end
