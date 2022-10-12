require 'rails_helper'

RSpec.describe AttachmentsController, type: :controller do
  let(:user) { create :user }
  before { sign_in user }

  describe 'Filters' do
    it { should use_before_action(:authenticate_user!) }
  end

  describe 'GET #index' do
    subject { get :index }

    context 'has at least one attachment' do
      let(:last_attachment) { user.attachments.last }
      before { create_list :attachment, 10, user_id: user.id }

      it 'redirect to the last attachment detail' do
        expect(subject).to redirect_to results_attachment_path(last_attachment)
      end
    end

    context 'not have any attachments' do
      it 'renders the page with an instantiated instance variable' do
        expect(subject).to render_template(:index)
        expect(assigns(:attachment)).to be_a(Attachment)
        expect(assigns(:attachment)).to be_new_record
      end
    end
  end

  describe 'GET #results' do
    subject { get :results, params: { id: attachment.id } }

    let(:attachment) { attachments.sample }
    let(:attachments) { create_list :attachment, 10, user_id: user.id }

    it 'renders the page with instance variables' do
      expect(subject).to render_template(:results)
      expect(assigns(:attachments)).to eq user.attachments.order(created_at: :desc)
      expect(assigns(:attachment)).to eq attachment
    end
  end

  describe 'POST #create' do
    subject { post :create, params: params }

    let(:attachment) { build :attachment }
    let(:params) do
      {
        attachment: {
          file: file
        }
      }
    end

    context 'with valid file' do
      let(:file) { fixture_file_upload('valid_file.csv', 'text/csv') }

      it 'create a new attachment and redirect the the detail page' do
        expect{ subject }.to change{ user.reload.attachments.size }.from(0).to(1)
        expect(subject).to redirect_to results_attachment_path(user.reload.attachments.last)
      end
    end

    context 'with invalid file' do
      let(:file) { fixture_file_upload('empty_file.csv', 'text/csv') }

      it 'send error message by worker' do
        expect{ subject }.to change(PushNotificationWorker.jobs, :size).by(1)
      end
    end
  end
end
