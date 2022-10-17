# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :attachment
  has_one :source_code, dependent: :destroy

  delegate :user, to: :attachment

  enum status: { fetching: 1, done: 2 }

  scope :by_keyword, lambda { |keyword|
    # rubocop:disable Style/StringConcatenation
    where('keyword LIKE ?', '%' + keyword + '%')
    # rubocop:enable Style/StringConcatenation
  }
end
