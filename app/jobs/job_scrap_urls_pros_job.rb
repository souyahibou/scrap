class JobScrapUrlsProsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JobScrapUrlsProsJob.set(wait: 1.day).perform_later
    ScrapUrlsPros.new.perform
  end
end

# wait_until: Date.tomorrow.noon
# wait: 1.week
