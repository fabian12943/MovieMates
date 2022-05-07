class User < ApplicationRecord
    has_secure_password

    validates :email, presence: true, uniqueness: { case_sensitive: false }, email: true, length: { maximum: 100 }
    validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 2, maximum: 25 }
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: false

    before_save { self.email.downcase!; self.username.downcase! }

end
