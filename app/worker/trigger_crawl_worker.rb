class TriggerCrawlWorker
  include Sidekiq::Job

  def perform(attachment_id = nil)
    fetching_results = Result.fetching.where(attachment_id: attachment_id)

    fetching_results.each do |result|
      CrawlGoogleDataWorker.perform_async(result.id)
    end
  end
end
