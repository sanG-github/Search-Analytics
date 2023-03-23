# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachmentsController, type: :controller do
  describe 'Filters' do
    it { should use_before_action(:authenticate_user!) }
  end

  describe 'GET #index' do
    context 'when the user has at least one attachment' do
      it 'redirects to the last attachment detail' do
        user = create :user
        create_list :attachment, 10, user_id: user.id
        last_attachment = user.attachments.last

        sign_in user
        get :index

        expect(response).to redirect_to results_attachment_path(last_attachment)
      end
    end

    context 'when the user does not have any attachments' do
      it 'renders the page with a new instantiated instance variable' do
        user = create :user

        sign_in user
        get :index

        expect(subject).to render_template(:index)
        expect(assigns(:attachment)).to be_a(Attachment)
        expect(assigns(:attachment)).to be_new_record
      end
    end
  end

  describe 'GET #results' do
    it 'renders the page with user attachments ordered by created_at DESC' do
      user = create :user
      attachments = create_list :attachment, 10, user_id: user.id
      attachment = attachments.sample

      sign_in user
      get :results, params: { id: attachment.id }

      expect(response).to render_template(:results)
      expect(assigns(:attachments)).to eq user.attachments.order(created_at: :desc)
      expect(assigns(:attachment)).to eq attachment
    end
  end

  describe 'POST #create' do
    context 'when a valid file is uploaded' do
      it 'creates a new attachment and redirects to the detail page' do
        user = create :user
        params = {
          attachment: {
            file: fixture_file_upload('valid_file.csv', 'text/csv')
          }
        }

        sign_in user
        post :create, params: params

        expect(user.attachments.size).to eq(1)
        expect(response).to redirect_to results_attachment_path(user.reload.attachments.last)
      end
    end

    context 'when an invalid file is uploaded' do
      it 'sends an error message by the worker' do
        user = create :user
        error_message = 'Cannot handle empty file!'
        params = {
          attachment: {
            file: fixture_file_upload('empty_file.csv', 'text/csv')
          }
        }

        sign_in user
        post :create, params: params

        expect(PushNotificationWorker.jobs.size).to eq(1)
        expect(PushNotificationWorker.jobs.first['args'][1]).to eq(error_message)
      end
    end
  end
end
