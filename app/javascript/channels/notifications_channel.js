import consumer from 'channels/consumer'

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connected")
  },

  disconnected() {
    console.log("Disconnected")
  },

  received(data) {
    if(data?.success)
      this.showSuccessNotification(data.message)
    else
      this.showFailureNotification(data.message())
  },

  showSuccessNotification(message) {
    toastr.success(message)
  },

  showFailureNotification(message) {
    toastr.error(message)
  }
});
