# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attachment, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:results) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
  end
end
