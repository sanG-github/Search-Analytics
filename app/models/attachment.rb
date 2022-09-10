# frozen_string_literal: true

class Attachment < ApplicationRecord
  belongs_to :user
  has_many :results

  validates :content, presence: true

  CSV_FILE_TYPE = 'text/csv'.freeze
  JSON_FILE_TYPE = 'application/json'.freeze
  VALID_FILE_TYPES = [CSV_FILE_TYPE, JSON_FILE_TYPE].freeze
end
