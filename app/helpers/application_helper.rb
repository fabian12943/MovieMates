module ApplicationHelper

    def formatted_duration(total_minutes)
        hours = total_minutes / 60
        minutes = (total_minutes) % 60
        "#{ hours }h #{ minutes }min"
    end

end
