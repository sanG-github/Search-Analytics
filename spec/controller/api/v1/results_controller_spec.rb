require 'rails_helper'

RSpec.describe Api::V1::ResultsController, type: :controller do
  describe 'Filters' do
    it { is_expected.to use_before_action(:authenticate_user!) }
  end

  describe 'GET #index' do
    context 'without params' do
      it 'returns success status' do
        user = create :user

        sign_in user
        get :index

        expect(response).to have_http_status :success
      end

      it 'returns all results of user' do
        number_of_results = 10
        attachment = create :attachment
        results = create_list :result, number_of_results, attachment: attachment

        sign_in attachment.user
        get :index

        expect(response.body).to eq(results.to_json)
      end
    end

    context 'when filtered by keyword' do
      it 'returns success status' do
        keyword = 'e'
        user = create :user

        sign_in user
        get :index, params: { q: keyword }

        expect(response).to have_http_status :success
      end

      it 'returns all filtered results of user' do
        keyword = 'e'
        attachment = create :attachment
        nimble_result = create :result, keyword: 'Nimble', attachment: attachment
        vietnam_result = create :result, keyword: 'VietNam', attachment: attachment
        _company_result = create :result, keyword: 'company', attachment: attachment
        expected_result = [nimble_result, vietnam_result].to_json

        sign_in attachment.user
        get :index, params: { q: keyword }

        expect(response.body).to eq(expected_result)
      end
    end
  end

  describe 'GET #show' do
    context 'given the user has the permission' do
      it 'returns success status' do
        attachment = create :attachment
        result = create :result, attachment: attachment

        sign_in attachment.user
        get :index, params: { id: result.id }

        expect(response).to have_http_status :success
      end

      it 'returns the result' do
        attachment = create :attachment
        result = create :result, attachment: attachment
        expected_result = result.to_json

        sign_in attachment.user
        get :show, params: { id: result.id }

        expect(response).to have_http_status :success
        expect(response.body).to eq(expected_result)
      end
    end

    context 'given the user does NOT have the permission' do
      it 'returns success status' do
        user = create :user
        another_user = create :user
        another_user_attachment = create :attachment, user: another_user
        another_user_result = create :result, attachment: another_user_attachment

        sign_in user
        get :show, params: { id: another_user_result.id }

        expect(response).to have_http_status :success
      end

      it 'returns nil for un-authored result' do
        user = create :user
        another_user = create :user
        another_user_attachment = create :attachment, user: another_user
        another_user_result = create :result, attachment: another_user_attachment

        sign_in user
        get :show, params: { id: another_user_result.id }

        expect(response.body).to eq(nil.to_json)
      end
    end
  end

  describe 'GET #keywords' do
    context 'given the user has many results' do
      it 'returns success status' do
        attachment = create :attachment
        create :result, keyword: 'Nimble', attachment: attachment
        create :result, keyword: 'VietNam', attachment: attachment

        sign_in attachment.user
        get :keywords

        expect(response).to have_http_status :success
      end

      it 'returns unique keywords in one attachment' do
        attachment = create :attachment

        nimble_result = create :result, keyword: 'Nimble', attachment: attachment
        vietnam_result = create :result, keyword: 'VietNam', attachment: attachment
        _second_nimble_result = create :result, keyword: 'Nimble', attachment: attachment
        _second_vietnam_result = create :result, keyword: 'VietNam', attachment: attachment

        sign_in attachment.user
        get :keywords
        result = JSON.parse(response.body)

        expect(result).to contain_exactly(nimble_result.keyword, vietnam_result.keyword)
      end

      it 'returns unique keywords in all attachments' do
        user = create :user
        attachment = create :attachment, user_id: user.id
        another_attachment = create :attachment, user_id: user.id

        nimble_result = create :result, keyword: 'Nimble', attachment_id: attachment.id
        company_result = create :result, keyword: 'company', attachment_id: attachment.id
        another_vietnam_result = create :result, keyword: 'VietNam', attachment_id: another_attachment.id
        _another_nimble_result = create :result, keyword: 'Nimble', attachment_id: another_attachment.id

        sign_in user
        get :keywords
        result = JSON.parse(response.body)

        expect(result).to contain_exactly(nimble_result.keyword, company_result.keyword, another_vietnam_result.keyword)
      end
    end

    context 'given the user does NOT have any results' do
      it 'returns success status' do
        user = create :user

        sign_in user
        get :keywords

        expect(response).to have_http_status :success
      end

      it 'returns an empty array' do
        user = create :user

        sign_in user
        get :keywords

        expect(response.body).to eq([].to_json)
      end
    end
  end
end
