require 'rails_helper'

RSpec.describe Api::V1::AttachmentsController, type: :controller do
  describe 'Filters' do
    it { should use_before_action(:authenticate_user!) }
  end

  describe 'POST #create' do
    context 'when a valid file is uploaded' do
      it 'creates a new attachment' do
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

    context 'when an invalid file is uploaded' do
      it 'returns an error message' do
        user = create :user
        error_message = 'Cannot handle empty file!'
        params = {
          file: fixture_file_upload('empty_file.csv', 'text/csv')
        }

        sign_in user
        post :create, params: params

        expect(json_response[:error]).to be_present
        expect(json_response[:error]).to eq(error_message)
      end
    end

    context 'when receive a StandardError from service' do
      it 'returns an error message' do
        user = create :user
        error_message = 'Error message from service'
        allow_any_instance_of(Attachments::CreateService).to receive(:call).and_raise(StandardError, error_message)

        sign_in user
        post :create

        expect(json_response[:error]).to be_present
        expect(json_response[:error]).to eq(error_message)
      end
    end
  end
end
