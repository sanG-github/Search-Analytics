# frozen_string_literal: true

class CrawlGoogleDataWorker
  include Sidekiq::Job

  def perform(result_id)
    CrawlGoogleDataService.new(result_id: result_id).call
  end
end
