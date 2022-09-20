class AttachmentsController < ApplicationController
  def index
    last_attachment = Attachment.where(user_id: current_user.id).last
    return redirect_to results_attachment_path(last_attachment) if last_attachment

    @attachment = Attachment.new
  end

  def results
    @attachments = Attachment.where(user_id: current_user.id).order(created_at: :desc)
    @attachment = Attachment.includes(:results).find_by(id: params[:id], user_id: current_user.id)
  end

  def create
    attachment = Attachments::CreateService.new(file: attachment_params[:file], user: current_user).call

    redirect_to results_attachment_path(attachment)
  rescue BehaviorError => e
    PushNotificationWorker.perform_async(current_user.id, e.response)
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
