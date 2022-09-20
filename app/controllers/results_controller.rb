class ResultsController < ApplicationController
  before_action :set_result, only: %i[show preview]

  def index
    @results = current_user.results.by_keyword(params[:q].to_s)
  end

  def show;end

  def preview
    render html: @result.source_code.content.html_safe
  end

  private

  def set_result
    @result = current_user.results.find_by(id: params[:id])
  end

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
