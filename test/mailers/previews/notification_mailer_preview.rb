class NotificationMailerPreview < ActionMailer::Preview

    def user_signup_confirmation
        user = User.first
        NotificationMailer.user_signup_confirmation(user)
    end

    def user_resend_confirmation_link
        user = User.first
        NotificationMailer.user_resend_confirmation_link(user)
    end
  
  end