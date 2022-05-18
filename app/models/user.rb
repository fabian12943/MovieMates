class User < ApplicationRecord
    include Gravtastic 
    gravtastic secure: true, filetype: :png, rating: 'pg', default: 'mp', size: 100

    has_secure_password

    attr_accessor :skip_password_validation

    validates :email, presence: true, uniqueness: { case_sensitive: false }, email: true, length: { maximum: 100 }
    validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 2, maximum: 25 }
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: false, unless: :skip_password_validation

    before_save { self.email.downcase!; self.username.downcase! }

    def self.from_omniauth(response)
        User.find_or_create_by(uid: response['uid'], provider: response['provider']) do |user|
            user.username = response['info']['nickname']
            user.email = response['info']['email']
            user.avatar_url = response['info']['image']
            user.password = SecureRandom.hex(15)
            user.ensure_username_uniqueness
        end
    end

    def ensure_username_uniqueness 
        if self.username.blank? || User.where(username: self.username).count > 0
          username_part = self.email.split("@").first
          new_username = username_part.dup 
          num = 2
          while(User.where(username: new_username).count > 0)
            new_username = "#{username_part}#{num}"
            num += 1
          end
          self.username = new_username
        end
      end

    def avatar_url
        self[:avatar_url].present? ? self[:avatar_url] : gravatar_url
    end

    def confirmed?
        self.confirmed_at != nil
    end

end
