require 'rails_helper'

RSpec.describe ResultsController, type: :controller do
  describe 'Filters' do
    it { should use_before_action(:authenticate_user!) }
  end

  describe 'GET #index' do
    context 'given the search parameter does NOT present' do
      it 'returns success status' do
        user = create :user

        sign_in user
        get :index

        expect(response).to have_http_status :success
      end

      it 'returns all results of the user' do
        user = create :user
        another_user = create :user
        number_of_results = 10
        attachment = create :attachment, user_id: user.id
        another_user_attachment = create :attachment, user_id: another_user.id
        create_list :result, number_of_results, attachment_id: attachment.id

        sign_in user
        get :index
        results = controller.instance_variable_get(:@results)

        expect(response).to have_http_status :success
        expect(results.size).to eq(number_of_results)
        expect(results.klass.name).to eq(Result.name)
        expect(results.pluck('DISTINCT attachment_id')).not_to include(another_user_attachment.id)
      end
    end

    context 'given the search parameter is present' do
      it 'returns success status' do
        keyword = 'e'
        user = create :user

        sign_in user
        get :index, params: { q: keyword }

        expect(response).to have_http_status :success
      end

      it 'returns all filtered results of the user' do
        keyword = 'e'
        user = create :user
        attachment = create :attachment, user_id: user.id
        nimble_result = create :result, keyword: 'Nimble', attachment_id: attachment.id
        vietnam_result = create :result, keyword: 'VietNam', attachment_id: attachment.id
        _company_result = create :result, keyword: 'company', attachment_id: attachment.id

        another_user = create :user
        another_user_attachment = create :attachment, user_id: another_user.id
        create :result, keyword: 'Nimble', attachment_id: another_user_attachment.id
        create :result, keyword: 'VietNam', attachment_id: another_user_attachment.id
        create :result, keyword: 'company', attachment_id: another_user_attachment.id

        sign_in user
        get :index, params: { q: keyword }
        results = controller.instance_variable_get(:@results)

        expect(results.size).to eq(2)
        expect(results).to contain_exactly(nimble_result, vietnam_result)
      end
    end
  end

  describe 'GET #show' do
    context 'given the user has the permission' do
      it 'returns success status' do
        user = create :user
        attachment = create :attachment, user_id: user.id
        result = create :result, attachment_id: attachment.id

        sign_in user
        get :show, params: { id: result.id }

        expect(response).to have_http_status :success
      end

      it 'returns the result of the user' do
        user = create :user
        attachment = create :attachment, user_id: user.id
        result = create :result, attachment_id: attachment.id

        sign_in user
        get :show, params: { id: result.id }

        expect(response).to have_http_status :success
        expect(controller.instance_variable_get(:@result)).to eq(result)
      end
    end

    context 'given the user does NOT have the permission' do
      it 'raises a record not found error' do
        user = create :user
        another_user = create :user
        another_user_attachment = create :attachment, user_id: another_user.id
        another_user_result = create :result, attachment_id: another_user_attachment.id

        sign_in user
        expect do
          get :show, params: { id: another_user_result.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
