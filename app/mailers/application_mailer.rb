class ApplicationMailer < ActionMailer::Base
  default from: "Movie-Mates <#{Rails.application.credentials.sendgrid ? Rails.application.credentials.sendgrid.email : ''}>"
  layout "mailer"
end
