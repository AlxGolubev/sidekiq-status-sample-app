class DataImportWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include Sidekiq::Status::Worker

  recurrence { hourly.minute_of_hour(*(0..59)) }
  STATUSES = [
    { percents: 0, message: '60 sec remaining' },
    { percents: 10, message: '54 sec remaining' },
    { percents: 20, message: '48 sec remaining' },
    { percents: 30, message: '42 sec remaining' },
    { percents: 40, message: '36 sec remaining' },
    { percents: 50, message: '30 sec remaining' },
    { percents: 60, message: '24 sec remaining' },
    { percents: 70, message: 'Almost done' },
    { percents: 80, message: 'Left just a little bit' },
    { percents: 90, message: 'And...' },
    { percents: 1000, message: 'We did it!' },
  ]

  def perform
    percents = 0

    loop do
      at percents, status_message(percents)
      break if percents == 100
      percents += 10
      sleep 6
    end
  end

  private

  def status_message(percents)
    STATUSES.select { |status| status[:percents] == percents }.first[:message]
  end
end
