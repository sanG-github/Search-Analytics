require 'rails_helper'

RSpec.describe Api::V1::AttachmentsController, type: :controller do
  describe 'Filters' do
    it { should use_before_action(:authenticate_user!) }
  end

  describe 'POST #create' do
    context 'when upload valid file' do
      it 'creates a new attachment and redirects to the detail page' do
        user = create :user
        params = {
          file: fixture_file_upload('valid_file.csv', 'text/csv')
        }

        sign_in user
        post :create, params: params

        expect(user.attachments.size).to eq(1)
        expect(response.body).to eq(user.attachments.last.to_json)
      end
    end

    context 'when upload invalid file' do
      it 'returns an error message' do
        user = create :user
        error_message = 'Cannot handle empty file!'
        params = {
          file: fixture_file_upload('empty_file.csv', 'text/csv')
        }

        sign_in user
        post :create, params: params
        result = JSON.parse(response.body)

        expect(result['error']).to be_present
        expect(result['error']).to eq(error_message)
      end
    end

    context 'when receive a StandardError from service' do
      it 'returns an error message' do
        user = create :user
        error_message = "Error message test"
        sign_in user
        allow_any_instance_of(Attachments::CreateService).to receive(:call).and_raise(StandardError, error_message)

        post :create
        result = JSON.parse(response.body)

        expect(result['error']).to be_present
        expect(result['error']).to eq(error_message)
      end
    end
  end
end
