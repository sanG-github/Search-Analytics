require 'rails_helper'

RSpec.describe Result, type: :model do
  describe 'associations' do
    it { should belong_to(:attachment) }
    it { should have_one(:source_code) }
  end
end
