require 'rails_helper'

RSpec.describe Attachments::CreateService, type: :service do
  describe '#call' do
    context 'given a valid file is uploaded' do
      it 'creates a new attachment with the file content' do
        user = create :user
        file = fixture_file_upload('valid_file.csv', 'text/csv')
        file_content = fixture_file_upload('valid_file.csv', 'text/csv').read

        subject = described_class.new(file: file, user: user)

        expect { subject.call }.to change { user.attachments.size }.by(1)
        expect(user.attachments.last.content).to eq(file_content)
      end

      it 'creates the corresponding results for user' do
        user = create :user
        file = fixture_file_upload('valid_file.csv', 'text/csv')
        file_content = fixture_file_upload('valid_file.csv', 'text/csv').read
        words = file_content.split(',').uniq

        described_class.new(file: file, user: user).call

        expect(user.results.pluck('keyword')).to contain_exactly(*words)
      end

      it 'enqueues a trigger crawl worker' do
        user = create :user
        file = fixture_file_upload('valid_file.csv', 'text/csv')
        worker_jobs = TriggerCrawlWorker.jobs

        described_class.new(file: file, user: user).call

        expect(worker_jobs.size).to eq(1)
        expect(worker_jobs.first['args'][0]).to eq(user.attachments.last.id)
      end
    end

    context 'given an INVALID file is uploaded' do
      context 'given the file with INVALID file type' do
        it 'raises an error message' do
          user = create :user
          file = fixture_file_upload('valid_file.csv', 'plaintext')
          error_message = 'Invalid file type'

          subject = described_class.new(file: file, user: user)

          expect { subject.call }.to raise_error(BehaviorError).with_message(error_message)
        end
      end

      context 'given the file caused the reading error' do
        it 'raises an error message' do
          user = create :user
          file = fixture_file_upload('valid_file.csv', 'text/csv')
          error_message = 'Error when read file'
          subject = described_class.new(file: file, user: user)

          allow_any_instance_of(File).to receive(:read).and_raise(StandardError)

          expect { subject.call }.to raise_error(BehaviorError).with_message(error_message)
        end
      end

      context 'given an empty file' do
        it 'raises an error message' do
          user = create :user
          file = fixture_file_upload('empty_file.csv', 'text/csv')
          error_message = 'Cannot handle empty file!'

          subject = described_class.new(file: file, user: user)

          expect { subject.call }.to raise_error(BehaviorError).with_message(error_message)
        end
      end

      context 'given the file containing keywords that exceed the maximum allowed' do
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
end
