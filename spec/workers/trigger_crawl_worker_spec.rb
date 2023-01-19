# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TriggerCrawlWorker, type: :job do
  describe '#perform' do
    context 'when attachment has many results' do
      context 'when attachment has many fetching results' do
        it 'enqueues each worker per fetching result' do
          number_of_results = FFaker::Number.number
          attachment = create :attachment
          worker_jobs = CrawlGoogleDataWorker.jobs
          _fetching_results = create_list :result, number_of_results, attachment_id: attachment.id, status: :fetching
          _done_results = create_list :result, FFaker::Number.number, attachment_id: attachment.id, status: :done

        described_class.new.perform(attachment.id)

        expect(worker_jobs.size).to eq(number_of_results)
      end
    end

      context 'when attachment does NOT have any fetching results' do
        it 'does nothing' do
          attachment = create :attachment
          worker_jobs = CrawlGoogleDataWorker.jobs
          _done_results = create_list :result, FFaker::Number.number, attachment_id: attachment.id, status: :done

          described_class.new.perform(attachment.id)

          expect(worker_jobs.size).to eq(0)
        end
      end
    end

    context 'when attachment does NOT have any results' do
      it 'does nothing' do
        attachment = create :attachment
        worker_jobs = CrawlGoogleDataWorker.jobs

        described_class.new.perform(attachment.id)

        expect(worker_jobs.size).to eq(0)
      end
    end
  end
end
