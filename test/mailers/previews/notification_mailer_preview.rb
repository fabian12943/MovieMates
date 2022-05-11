class NotificationMailerPreview < ActionMailer::Preview

    def user_signup_confirmation
        user = User.first
        NotificationMailer.user_signup_confirmation(user)
    end
  
  end