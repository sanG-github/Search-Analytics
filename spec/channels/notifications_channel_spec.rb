require 'rails_helper'

RSpec.describe NotificationsChannel, type: :channel do
  let(:user) { User.create(email: 'hihi@gmail.com', password: 'test', password_confirmation: 'test') }

  before do
    stub_connection current_user: user
  end

  it 'subscribes successfully' do
    subscribe
    expect(subscription).to be_confirmed
  end
end
