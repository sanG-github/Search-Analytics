# frozen_string_literal: true

class PushResultService
  def initialize(user_id:, data:)
    @user_id = user_id
    @data = data
  end

  def call
    ActionCable.server.broadcast(stream_name, @data)
  rescue StandardError => e
    raise PushResultError, e.message
  end

  private

  def stream_name
    "results_#{@user_id}"
  end
end
