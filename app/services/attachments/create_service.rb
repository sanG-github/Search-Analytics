# frozen_string_literal: true

module Attachments
  class CreateService
    def initialize(file:, user:)
      @file = file
      @user = user
      @file_content = nil
    end

    def call
      raise 'File not found' unless file
      raise 'Invalid file type' unless valid_file?

      # keywords is a CSV separated by comma (,)
      keywords = parse_csv_data

      raise 'Cannot handle empty file!' unless file_content.present? && keywords&.size
      raise "Only accept files containing up to #{MAX_KEYWORDS} keywords" if keywords.size > MAX_KEYWORDS

      attachment = user.attachments.create!(content: file_content, name: file.original_filename)
      attachment.results.create!(keywords.map { { keyword: _1 } })

      ::TriggerCrawlWorker.perform_async(attachment.id)

      attachment
    rescue StandardError => e
      raise CreateAttachmentError, e.message
    end

    private

    attr_reader :file, :file_content, :user

    def valid_file?
      Attachment::VALID_FILE_TYPES.include?(file.content_type)
    end

    def parse_csv_data
      separator = ','

      @file_content = file.read
      @file_content.split(separator).uniq
    rescue StandardError
      raise 'Error when read file'
    end
  end
end
