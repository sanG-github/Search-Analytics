# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :attachment
  has_one :source_code, dependent: :destroy

  delegate :user, to: :attachment

  enum status: { fetching: 1, done: 2 }

  scope :by_keyword, lambda { |keyword|
    where('keyword LIKE ?', '%' + keyword+ '%')
  }
end
