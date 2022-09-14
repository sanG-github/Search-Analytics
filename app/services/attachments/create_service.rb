module Attachments
  class CreateService
    def initialize(file:, user:)
      @file = file
      @user = user
    end

    def call
      raise 'File not found' unless file
      raise 'Invalid file type' unless valid_file?

      # keywords is a CSV separated by comma (,)
      keywords = parse_csv_data

      raise 'Empty file' unless file_content.present? && keywords&.size
      raise "Only accept files containing up to #{MAX_KEYWORDS} keywords" if keywords.size > MAX_KEYWORDS

      attachment = Attachment.create!(content: file_content, user: user)
      attachment.results.create!(keywords.map { { keyword: _1 } })

      ::TriggerCrawlWorker.perform_async(attachment.id)

      attachment
    end

    private

    attr_reader :file, :file_content, :user

    def valid_file?
      Attachment::VALID_FILE_TYPES.include?(file.content_type)
    end

    def parse_csv_data
      separator = ','.freeze

      @file_content = file.read
      @file_content.split(separator).uniq
    rescue StandardError
      raise 'Error when read file'
    end
  end
end
