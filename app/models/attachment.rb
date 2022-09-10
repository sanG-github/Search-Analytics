class Attachment < ApplicationRecord
  belongs_to :user
  has_many :results

  validates :content, presence: true
end
