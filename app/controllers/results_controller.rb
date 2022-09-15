class ResultsController < ApplicationController
  def index
    @results = current_user.results
    @results = @results.where('keyword LIKE ?', "%" + params[:q] + "%") if params[:q].present?
  end

  def show
    @result = current_user.results.find_by(id: params[:id])
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
