class PushNotificationWorker
  include Sidekiq::Job

  def perform(user_id, data)
    @user_id = user_id

    ActionCable.server.broadcast(stream_name, data)
  end

  private

  def stream_name
    "notifications_#{@user_id}"
  end
end
