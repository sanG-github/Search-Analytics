require 'rails_helper'

RSpec.describe AttachmentsController, type: :controller do
  let(:user) { create :user }
  before { sign_in user }

  describe 'Filters' do
    it { should use_before_action(:authenticate_user!) }
  end

  describe 'GET #index' do
    context 'when the user has at least one attachment' do
      it 'redirect to the last attachment detail' do
        create_list :attachment, 10, user_id: user.id
        last_attachment = user.attachments.last

        get :index

        expect(response).to redirect_to results_attachment_path(last_attachment)
      end
    end

    context 'not have any attachments' do
      it 'renders the page with an instantiated instance variable' do
        get :index

        expect(subject).to render_template(:index)
        expect(assigns(:attachment)).to be_a(Attachment)
        expect(assigns(:attachment)).to be_new_record
      end
    end
  end

  describe 'GET #results' do
    it 'renders the page with instance variables' do
      attachments = create_list :attachment, 10, user_id: user.id
      attachment = attachments.sample

      get :results, params: { id: attachment.id }

      expect(response).to render_template(:results)
      expect(assigns(:attachments)).to eq user.attachments.order(created_at: :desc)
      expect(assigns(:attachment)).to eq attachment
    end
  end

  describe 'POST #create' do
    context 'with valid file' do
      it 'create a new attachment and redirect the the detail page' do
        params = {
          attachment: {
            file: fixture_file_upload('valid_file.csv', 'text/csv')
          }
        }
        post :create, params: params

        expect(user.attachments.size).to eq(1)
        expect(response).to redirect_to results_attachment_path(user.reload.attachments.last)
      end
    end

    context 'with invalid file' do
      it 'send error message by worker' do
        params = {
          attachment: {
            file: fixture_file_upload('empty_file.csv', 'text/csv')
          }
        }
        post :create, params: params

        expect(PushNotificationWorker.jobs.size).to eq(1)
      end
    end
  end
end
