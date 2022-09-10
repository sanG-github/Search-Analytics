class Attachments::CreateService
  def initialize(params:)
    @file = params[:file]
  end

  def call
    raise "File not found" unless file
    raise "Invalid file type" unless valid_file?

    handle_file
  end

  private

  attr_reader :file

  def valid_file?
    Attachment::VALID_FILE_TYPES.include?(file.content_type)
  end

  def json_file?
    Attachment::JSON_FILE_TYPE == file.content_type
  end

  def csv_file?
    Attachment::CSV_FILE_TYPE == file.content_type
  end

  def handle_file
    data = JSON.parse(file.read) if json_file?
    data = file.read if csv_file?

    data
  rescue JSON::ParserError
    raise "JSON file with wrong format"
  rescue StandardError
    raise "Error when read file"
  end
end