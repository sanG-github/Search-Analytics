require 'rails_helper'

RSpec.describe Result, type: :model do
  describe 'associations' do
    it { should belong_to(:attachment) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
  end
end
