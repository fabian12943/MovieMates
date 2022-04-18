class UpdatePopularPeopleWorker
    include Sidekiq::Worker

    def perform
        People::Popular.update
    end

end