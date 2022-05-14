class NotificationMailer < ApplicationMailer

    def user_signup_confirmation(user)
        @user = user
        @token = user.signed_id(expires_in: 1.day, purpose: :account_confirmation)
        mail( to: @user.email,
              subject: I18n.t('notification_mailer.user_signup_confirmation.subject') )
    end

    def user_resend_confirmation_link(user)
        @user = user
        @token = user.signed_id(expires_in: 1.day, purpose: :account_confirmation)
        mail( to: @user.email,
              subject: I18n.t('notification_mailer.user_resend_confirmation_link.subject') )
    end
    
  end
  