class TriggerCrawlWorker
  include Sidekiq::Job

  def perform(attachment_id = nil)
    fetching_keywords = Result.fetching.where(attachment_id: attachment_id)

    fetching_keywords.each do |keyword|
      CrawlGoogleDataWorker.new(keyword).perform
    end
  end
end
