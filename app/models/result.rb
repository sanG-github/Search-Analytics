class Result < ApplicationRecord
  belongs_to :attachment
  has_one :source_code

  enum status: { fetching: 1, done: 2 }
end
