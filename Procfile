web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 20
release: bundle exec rake db:migrate