require 'rails_helper'

RSpec.describe Attachments::CreateService, type: :service do
  describe '#call' do
    context 'when upload a valid file' do
      it 'creates a new attachment and enqueued crawl keywords worker' do
        user = create :user
        file = fixture_file_upload('valid_file.csv', 'text/csv')
        file_content = fixture_file_upload('valid_file.csv', 'text/csv').read
        separated_file_content = file_content.split(',').uniq

        subject = described_class.new(file: file, user: user)
        worker_jobs = TriggerCrawlWorker.jobs

        expect { subject.call }.to change { user.attachments.size }.by(1)
        expect(user.attachments.last.content).to eq(file_content)
        expect(user.results.size).to eq(separated_file_content.size)
        expect(user.results.pluck('DISTINCT keyword')).to include(*separated_file_content)
        expect(worker_jobs.size).to eq(1)
        expect(worker_jobs.first['args'][0]).to eq(user.attachments.last.id)
      end
    end

    context 'when upload an invalid file type' do
      it 'raises an error message' do
        user = create :user
        file = fixture_file_upload('valid_file.csv', 'plaintext')
        error_message = 'Invalid file type'

        subject = described_class.new(file: file, user: user)

        expect { subject.call }.to raise_error(BehaviorError).with_message(error_message)
      end
    end

    context 'when reading the file and an error occurs' do
      it 'raises an error message' do
        user = create :user
        file = fixture_file_upload('valid_file.csv', 'text/csv')
        error_message = 'Error when read file'

        allow_any_instance_of(File).to receive(:read).and_raise(StandardError)

        subject = described_class.new(file: file, user: user)
        expect { subject.call }.to raise_error(BehaviorError).with_message(error_message)
      end
    end

    context 'when upload an empty file' do
      it 'raises an error message' do
        user = create :user
        file = fixture_file_upload('empty_file.csv', 'text/csv')
        error_message = 'Cannot handle empty file!'

        subject = described_class.new(file: file, user: user)

        expect { subject.call }.to raise_error(BehaviorError).with_message(error_message)
      end
    end

    context 'when upload file containing keywords that exceed the maximum allowed' do
      it 'raises an error message' do
        user = create :user
        file = fixture_file_upload('exceed_keywords_allowed_file.csv', 'text/csv')
        error_message = "Only accept files containing up to #{MAX_KEYWORDS} keywords"

        subject = described_class.new(file: file, user: user)

        expect { subject.call }.to raise_error(BehaviorError).with_message(error_message)
      end
    end
  end
end
