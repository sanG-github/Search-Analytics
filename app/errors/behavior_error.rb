# frozen_string_literal: true

class BehaviorError < StandardError
  attr_accessor :message

  def initialize(message = nil)
    @message = message
  end

  def response
    {
      success: false,
      message: message
    }
  end
end
