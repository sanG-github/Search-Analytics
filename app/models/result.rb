class Result < ApplicationRecord
  belongs_to :attachment

  enum status: { fetching: 1, done: 2 }
end
