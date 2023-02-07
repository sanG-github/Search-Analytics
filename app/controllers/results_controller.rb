# frozen_string_literal: true

class ResultsController < ApplicationController
  def index
    @results = current_user.results.by_keyword(params[:q].to_s)
  end

  def show
    @result = current_user.results.find(params[:id])
  end
end
