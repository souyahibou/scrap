class JobScrapUrlsProsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JobScrapUrlsProsJob.set(wait_until: (Date.tomorrow + 7.hours)).perform_later
    ScrapUrlsPros.new.perform
  end
end

# wait_until: Date.tomorrow.noon
# wait: 1.week
