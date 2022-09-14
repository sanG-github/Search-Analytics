class ResultsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "results_#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
