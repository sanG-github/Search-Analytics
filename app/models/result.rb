class Result < ApplicationRecord
  belongs_to :attachment
  has_one :source_code

  delegate :user, to: :attachment

  enum status: { fetching: 1, done: 2 }
end
