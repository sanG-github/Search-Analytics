require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.describe CrawlGoogleDataService, type: :service do
  describe '#call' do
    context 'when result not found' do
      it 'does NOT raise an error' do
        wrong_result_id = 999
        subject = described_class.new(result_id: wrong_result_id)

        expect { subject.call }.not_to raise_error
      end

      it 'writes a warning log' do
        wrong_result_id = 999
        subject = described_class.new(result_id: wrong_result_id)
        error_message = "Couldn't find Result with 'id'=#{wrong_result_id}"
        allow(Rails.logger).to receive(:warn)

        subject.call

        expect(Rails.logger).to have_received(:warn).with("CrawlGoogleDataService#call: #{error_message}").once
      end
    end

    context 'when fetch result successfully' do
      it 'updates the result record' do
        keyword = 'nimble'
        result = create :result, keyword: keyword, status: :fetching
        subject = described_class.new(result_id: result.id)

        VCR.use_cassette("nimble_result") do
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

        VCR.use_cassette("nimble_result") do
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

        VCR.use_cassette("nimble_result") do
          subject.call

          expect(worker_jobs.size).to eq(1)
          expect(worker_jobs.first['args'][0]).to eq(result.user.id)
        end
      end
    end

    context 'when fetch result failed' do
      it 'rollbacks from start' do
        keyword = 'nimble'
        result = create :result, keyword: keyword, status: :fetching
        subject = described_class.new(result_id: result.id)

        allow_any_instance_of(Result).to receive(:create_source_code!).and_raise(StandardError)

        VCR.use_cassette("nimble_result") do
          expect { subject.call }
            .to not_change { result.reload.total_ads }
            .and not_change { result.reload.total_links }
            .and not_change { result.reload.total_results }
            .and not_change { result.reload.status }
        end
      end

      it 'does NOT enqueue PushResultWorker' do
        keyword = 'nimble'
        result = create :result, keyword: keyword, status: :fetching
        subject = described_class.new(result_id: result.id)

        allow_any_instance_of(Result).to receive(:create_source_code!).and_raise(StandardError)

        VCR.use_cassette("nimble_result") do
          subject.call

          expect(PushResultWorker.jobs.size).to eq(0)
        end
      end

      it 'writes a warning log' do
        keyword = 'nimble'
        result = create :result, keyword: keyword, status: :fetching
        subject = described_class.new(result_id: result.id)
        error_message = 'StandardError'

        allow_any_instance_of(Result).to receive(:create_source_code!).and_raise(StandardError)
        allow(Rails.logger).to receive(:warn)

        VCR.use_cassette("nimble_result") do
          subject.call

          expect(Rails.logger).to have_received(:warn).with("CrawlGoogleDataService#call: #{error_message}").once
        end
      end
    end
  end
end
