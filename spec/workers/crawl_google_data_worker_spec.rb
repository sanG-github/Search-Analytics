# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CrawlGoogleDataWorker, type: :job do
  describe '#perform' do
    it 'calls the respective service' do
      result = create(:result)
      crawl_google_data_service = instance_double(CrawlGoogleDataService)

      expect(CrawlGoogleDataService)
        .to receive(:new)
        .with(result_id: result.id)
        .and_return(crawl_google_data_service)
      expect(crawl_google_data_service)
        .to receive(:call)

      described_class.new.perform(result.id)
    end
  end
end
