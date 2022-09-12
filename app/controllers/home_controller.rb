class HomeController < ApplicationController
  def index
    @attachment = Attachment.new
  end
end
