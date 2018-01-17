class JobScrapUrlsProsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    JobScrapUrlsProsJob.set(wait: 1.minute).perform_later
    p "Hello It is" + Time.now.to_s
  end
end
