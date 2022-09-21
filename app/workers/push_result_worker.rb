# frozen_string_literal: true

class PushResultWorker
  include Sidekiq::Job

  def perform(user_id, data)
    PushResultService.new(user_id: user_id, data: data).call
  end
end
