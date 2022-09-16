class Api::V1::ApplicationController < ActionController::Base
  before_action :authenticate_user!
end
