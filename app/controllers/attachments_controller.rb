class AttachmentsController < ApplicationController
  def create
    result = Attachments::CreateService.new(file: attachment_params[:file]).call

    render json: result
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
