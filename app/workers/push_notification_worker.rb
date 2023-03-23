# frozen_string_literal: true

class PushNotificationWorker
  include Sidekiq::Job

  def perform(user_id, data)
    PushNotificationService.new(user_id: user_id, data: data).call
  end
end
