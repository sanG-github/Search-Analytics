# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PushResultWorker, type: :job do
  describe '#perform' do
    it 'calls the respective service' do
      user = create(:user)
      data = {}
      stream_name = "results_#{user.id}"

      expect(ActionCable.server)
        .to receive(:broadcast)
        .with(stream_name, data)

      described_class.new.perform(user.id, data)
    end
  end
end

