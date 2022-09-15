// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "jquery"
import "jquery_ujs"
import "toastr"
import "@hotwired/turbo-rails"
import "controllers"
import "channels"
import listenUploadFile from "./homepages/listen_upload_file";

toastr.options = {
  "closeButton": true,
  "debug": false,
  "newestOnTop": true,
  "progressBar": true,
  "preventDuplicates": true,
  "onclick": null,
  "showDuration": "300",
  "hideDuration": "500",
  "timeOut": "2500",
  "extendedTimeOut": "500",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut",
  "positionClass": "toast-top-right"
}

document.addEventListener("turbo:load", () => {
  listenUploadFile.initialize();
});
