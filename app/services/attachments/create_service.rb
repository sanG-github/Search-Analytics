module Attachments
  class CreateService
    def initialize(file:, user:)
      @file = file
      @user = user
    end

    def call
      raise 'File not found' unless file
      raise 'Invalid file type' unless valid_file?

      # keywords is a 1 dimension array, example: ["key", "word"]
      keywords = parse_data

      raise 'Empty file' unless file_content && keywords&.size

      attachment = Attachment.create!(content: file_content, user: user)
      attachment.results.create!(keywords.map { { keyword: _1 } })

      ::TriggerCrawlWorker.perform_async(attachment.id)
    end

    private

    attr_reader :file, :file_content, :user

    def valid_file?
      Attachment::VALID_FILE_TYPES.include?(file.content_type)
    end

    def json_file?
      file.content_type == JSON_FILE_TYPE
    end

    def csv_file?
      file.content_type == CSV_FILE_TYPE
    end

    def parse_json_data
      # TODO: verify that file is a array and only 1 dimension
      @file_content = JSON.parse(file.read)
      @file_content.uniq
    end

    def parse_csv_data
      separator = ','.freeze

      @file_content = file.read
      @file_content.split(separator).uniq
    end

    def parse_data
      parse_json_data if json_file?
      parse_csv_data if csv_file?
    rescue JSON::ParserError
      raise 'JSON file with wrong format'
    rescue StandardError
      raise 'Error when read file'
    end
  end
end
