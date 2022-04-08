class Cast < ApplicationRecord
    has_many :details, class_name: "CastDetailSet", foreign_key: "cast_id", dependent: :destroy
    
end
