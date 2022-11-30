class PushNotificationService
  def initialize(user_id:, data:)
    @user_id = user_id
    @data = data
  end

  def call
    ActionCable.server.broadcast(stream_name, @data)
  rescue StandardError => e
    raise PushNotificationError, e.message
  end

  private

  def stream_name
    "notifications_#{@user_id}"
  end
end