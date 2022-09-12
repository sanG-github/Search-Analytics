class CrawlGoogleDataWorker
  include Sidekiq::Job

  def perform(keyword = nil)
    CrawlGoogleDataService.new(keyword: keyword).call
  end
end
