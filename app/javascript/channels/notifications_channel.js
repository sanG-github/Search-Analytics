import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connected")
  },

  disconnected() {
    console.log("Disconnected")
  },

  received(data) {
    console.log(data)
  }
});
