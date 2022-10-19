require 'rails_helper'

RSpec.describe Api::V1::ResultsController, type: :controller do
  describe 'Filters' do
    it { is_expected.to use_before_action(:authenticate_user!) }
  end

  describe 'GET #index' do
    context 'without params' do
      it 'returns all results of user' do
        user = create :user
        number_of_results = 10
        attachment = create :attachment, user_id: user.id
        create_list :result, number_of_results, attachment_id: attachment.id
        returned_result = user.results.to_json

        sign_in user
        get :index

        expect(response).to have_http_status :success
        expect(response.body).to eq(returned_result)
      end
    end

    context 'when filtered by keyword' do
      it 'returns all filtered results of user' do
        keyword = 'e'
        user = create :user
        attachment = create :attachment, user_id: user.id
        nimble_result = create :result, keyword: 'Nimble', attachment_id: attachment.id
        vietnam_result = create :result, keyword: 'VietNam', attachment_id: attachment.id
        _company_result = create :result, keyword: 'company', attachment_id: attachment.id
        returned_result = [nimble_result, vietnam_result].to_json

        sign_in user
        get :index, params: { q: keyword }

        expect(response).to have_http_status :success
        expect(response.body).to eq(returned_result)
      end
    end
  end

  describe 'GET #show' do
    it 'returns result of user' do
      user = create :user
      attachment = create :attachment, user_id: user.id
      result = create :result, attachment_id: attachment.id
      params = { id: result.id }
      returned_result = result.to_json

      sign_in user
      get :show, params: params

      expect(response).to have_http_status :success
      expect(response.body).to eq(returned_result)
    end

    it 'returns nil for un-authored result' do
      user = create :user
      other_user = create :user
      un_authored_attachment = create :attachment, user_id: other_user.id
      un_authored_result = create :result, attachment_id: un_authored_attachment.id
      params = { id: un_authored_result.id }
      returned_result = nil.to_json

      sign_in user
      get :show, params: params

      expect(response).to have_http_status :success
      expect(response.body).to eq(returned_result)
    end
  end

  describe 'GET #keywords' do
    it 'returns unique keywords' do
      user = create :user
      attachment = create :attachment, user_id: user.id

      nimble_result = create :result, keyword: 'Nimble', attachment_id: attachment.id
      _second_nimble_result = create :result, keyword: 'Nimble', attachment_id: attachment.id
      vietnam_result = create :result, keyword: 'VietNam', attachment_id: attachment.id
      _second_vietnam_result = create :result, keyword: 'VietNam', attachment_id: attachment.id

      sign_in user
      get :keywords
      result = JSON.parse(response.body)

      expect(response).to have_http_status :success
      expect(result.size).to eq(2)
      expect(result).to include(nimble_result.keyword, vietnam_result.keyword)
    end

    it 'returns unique keywords in all attachments' do
      user = create :user
      attachment = create :attachment, user_id: user.id
      other_attachment = create :attachment, user_id: user.id

      nimble_result = create :result, keyword: 'Nimble', attachment_id: attachment.id
      company_result = create :result, keyword: 'company', attachment_id: attachment.id
      _other_nimble_result = create :result, keyword: 'Nimble', attachment_id: other_attachment.id
      other_vietnam_result = create :result, keyword: 'VietNam', attachment_id: other_attachment.id

      sign_in user
      get :keywords
      result = JSON.parse(response.body)

      expect(response).to have_http_status :success
      expect(result.size).to eq(3)
      expect(result).to include(nimble_result.keyword, company_result.keyword, other_vietnam_result.keyword)
    end

    it 'does NOT have any keywords' do
      user = create :user

      sign_in user
      get :keywords
      returned_result = [].to_json

      expect(response).to have_http_status :success
      expect(response.body).to eq(returned_result)
    end
  end
end
