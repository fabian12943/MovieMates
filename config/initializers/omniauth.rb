Rails.application.config.middleware.use OmniAuth::Builder do
    provider :github, Rails.application.credentials.github_oauth[Rails.env].client_id, Rails.application.credentials.github_oauth[Rails.env].client_secret, 
        scope: "user:email", origin_param: 'return_to'
end