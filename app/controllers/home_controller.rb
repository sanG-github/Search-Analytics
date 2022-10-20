# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @attachment = Attachment.new
  end
end
