web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 3 -e production
release: bundle exec rake db:migrate