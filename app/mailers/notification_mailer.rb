class NotificationMailer < ApplicationMailer

    def user_signup_confirmation(user)
        @user = user
        @token = user.signed_id(expires_in: 1.day, purpose: :signup_confirmation)
        mail( to: @user.email,
              subject: I18n.t('notification_mailer.user_signup_confirmation.subject') )
    end
    
  end
  