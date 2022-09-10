module Attachments
  class CreateService
    def initialize(file:)
      @file = file
    end

    def call
      raise 'File not found' unless file
      raise 'Invalid file type' unless valid_file?

      handle_file
    end

    private

    attr_reader :file

    def valid_file?
      Attachment::VALID_FILE_TYPES.include?(file.content_type)
    end

    def json_file?
      file.content_type == JSON_FILE_TYPE
    end

    def csv_file?
      file.content_type == CSV_FILE_TYPE
    end

    def handle_file
      data = JSON.parse(file.read) if json_file?
      data = file.read if csv_file?

      data
    rescue JSON::ParserError
      raise 'JSON file with wrong format'
    rescue StandardError
      raise 'Error when read file'
    end
  end
end
