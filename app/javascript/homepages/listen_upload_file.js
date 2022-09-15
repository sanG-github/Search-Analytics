const listenUploadFile = {
  uploadBtn: "#upload_file",
  hiddenUploadBtn: "#hidden_upload_file",
  submitAttachmentBtn: "#new_attachment",

  initialize: function() {
    this.listenUpload();
    this.handleAutoSubmit();
  },

  listenUpload: function() {
    $(this.uploadBtn).on("click", () => {
      $(this.hiddenUploadBtn).click()
    })
  },

  handleAutoSubmit: function() {
    $(this.hiddenUploadBtn).on("change", () => {
      $(this.submitAttachmentBtn).submit()
    })
  }
}

export default listenUploadFile;
