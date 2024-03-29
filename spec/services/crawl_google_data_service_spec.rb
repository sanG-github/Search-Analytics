# frozen_string_literal: true

require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.describe CrawlGoogleDataService, type: :service do
  describe '#call' do
    context 'when result not found' do
      it 'raises an error' do
        wrong_result_id = 999
        subject = described_class.new(result_id: wrong_result_id)

        expect { subject.call }.to raise_error(CrawlGoogleError)
      end
    end

    context 'when fetch result successfully' do
      it 'updates the result record' do
        keyword = 'nimble'
        result = create :result, keyword: keyword, status: :fetching
        subject = described_class.new(result_id: result.id)

        VCR.use_cassette('search_results/nimble') do
          expect { subject.call }
            .to change { result.reload.total_ads }
            .and change { result.reload.total_links }
            .and change { result.reload.total_results }
            .and change { result.reload.status }.from('fetching').to('done')
        end
      end

      it 'creates a new source_code' do
        keyword = 'nimble'
        result = create :result, keyword: keyword, status: :fetching
        subject = described_class.new(result_id: result.id)

        VCR.use_cassette('search_results/nimble') do
          expect do
            subject.call
          end.to change(SourceCode, :count).by(1)
          expect(result.source_code).to be_present
        end
      end

      it 'enqueues a PushResultWorker to update UI' do
        keyword = 'nimble'
        result = create :result, keyword: keyword, status: :fetching
        subject = described_class.new(result_id: result.id)
        worker_jobs = PushResultWorker.jobs

        VCR.use_cassette('search_results/nimble') do
          subject.call

          expect(worker_jobs.size).to eq(1)
          expect(worker_jobs.first['args'][0]).to eq(result.user.id)
        end
      end
    end

    context 'when fetch result failed' do
      it 'rollbacks the result creation' do
        keyword = 'nimble'
        result = create :result, keyword: keyword, status: :fetching
        subject = described_class.new(result_id: result.id)

        allow_any_instance_of(Result).to receive(:create_source_code!).and_raise('Error message')

        VCR.use_cassette('search_results/nimble') do
          expect { subject.call }.to raise_error(CrawlGoogleError, 'Error message')
            .and not_change(result, :total_ads)
            .and not_change(result, :total_links)
            .and not_change(result, :total_results)
            .and not_change(result, :status)
        end
      end

      it 'does NOT enqueue PushResultWorker' do
        keyword = 'nimble'
        result = create :result, keyword: keyword, status: :fetching
        subject = described_class.new(result_id: result.id)

        allow_any_instance_of(Result).to receive(:create_source_code!).and_raise('Error message')

        VCR.use_cassette('search_results/nimble') do
          expect { subject.call }.to raise_error(CrawlGoogleError, 'Error message')
          expect(PushResultWorker.jobs.size).to eq(0)
        end
      end
    end
  end
end
