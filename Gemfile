source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.2", ">= 7.0.2.3"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Haml accelerates and simplifies template creation down to veritable haiku
gem "haml", "~> 5.2"

# Use Sass to process CSS
gem "sassc-rails"

# Ruby wrapper to provide a simple, easy to use interface for the Movie Database API
gem "themoviedb", "~> 1.0"

# Present users countries/languages in their language
gem "i18n_data", "~> 0.16.0"

# Centralization of locale data collection for Ruby on Rails
gem "rails-i18n", "~> 7.0.0"

# Embed SVG documents in Rails views and style them with CSS
gem "inline_svg", "~> 1.8"

# Simple, efficient background processing for Ruby
gem "sidekiq", "~> 6.4"

# Sidekiq-Cron runs a thread alongside Sidekiq workers to schedule jobs at specified times
gem "sidekiq-cron", "~> 1.3"

# Detect the users preferred language, as sent by the "Accept-Language" HTTP header
gem 'http_accept_language'

# Alternative implementation to the URI implementation that is part of Ruby's standard library
gem "addressable", "~> 2.8"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1"

# OmniAuth is a flexible authentication system utilizing Rack middleware
gem 'omniauth'
gem "omniauth-rails_csrf_protection"

# GitHub strategy for OmniAuth
gem 'omniauth-github', github: 'omniauth/omniauth-github', branch: 'master'

# Rack middleware to redirect legacy domains
gem 'rack-host-redirect'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Solargraph is a language server that provides intellisense, code completion, and inline documentation for Ruby
  gem "solargraph", "~> 0.44.3"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
