const listenUploadFile = {
  uploadBtn: document.getElementById("upload_file"),
  hiddenUploadBtn: document.getElementById("hidden_upload_file"),
  submitAttachmentBtn: document.getElementById("new_attachment"),

  initialize: function() {
    this.listenUpload();
    this.handleAutoSubmit();
  },

  listenUpload: function() {
    this.uploadBtn?.addEventListener("click", () => {
      this.hiddenUploadBtn.click()
    })
  },

  handleAutoSubmit: function() {
    this.hiddenUploadBtn?.addEventListener("change", () => {
      this.submitAttachmentBtn.submit()
    })
  }
}

export default listenUploadFile;
