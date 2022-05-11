# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# Deactivate field error proc.
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag.html_safe
end

ActionMailer::Base.smtp_settings = {
    :user_name => 'apikey',
    :password => Rails.application.credentials.sendgrid.api_key,
    :domain => 'localhost.com:3000',
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
}
  
