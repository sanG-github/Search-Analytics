import consumer from "channels/consumer"

consumer.subscriptions.create("ResultsChannel", {
  connected() {
    console.log("Connected Results")
  },

  disconnected() {
    console.log("Disconnected Results")
  },

  received(data) {
    const attachment_id = data.attachment_id
    const result_id = data.result_id
    const total_ads = data.total_ads
    const total_links = data.total_links
    const total_results = data.total_results

    const row = $(`table[data-attachment-id=${attachment_id}] [data-result-id=${result_id}]`)

    if(!row) return;

    row.find('#total_ads').text(total_ads)
    row.find('#total_links').text(total_links)
    row.find('#total_results').text(total_results)
  }
});
