class AttachmentsController < ApplicationController
  def create
    result = Attachments::CreateService.new(params: attachment_params).call

    render json: result
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end