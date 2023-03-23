# frozen_string_literal: true

module Api
  module V1
    class AttachmentsController < Api::V1::ApplicationController
      def create
        attachment = Attachments::CreateService.new(file: attachment_params[:file], user: current_user).call

        render json: attachment
      rescue CreateAttachmentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def attachment_params
        params.permit(:file)
      end
    end
  end
end
