class SourceCode < ApplicationRecord
  belongs_to :result

  validates :content, presence: true
end
