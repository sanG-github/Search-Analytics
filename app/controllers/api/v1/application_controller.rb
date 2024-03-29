# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :null_session

      before_action :authenticate_user!
    end
  end
end
