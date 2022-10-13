require 'rails_helper'

RSpec.describe ResultsController, type: :controller do
  let(:user) { create :user }
  let(:other_user) { create :user }
  before { sign_in user }

  describe 'Filters' do
    it { should use_before_action(:authenticate_user!) }
  end

  describe 'GET #index' do
    context 'without params' do
      it 'returns all results of user' do
        number_of_results = 10
        attachment = create :attachment, user_id: user.id
        un_authored_attachment = create :attachment, user_id: other_user.id
        create_list :result, number_of_results, attachment_id: attachment.id

        get :index
        results = controller.instance_variable_get(:@results)

        expect(response).to have_http_status :success
        expect(results.size).to eq(number_of_results)
        expect(results.klass.name).to eq(Result.name)
        expect(results.pluck('DISTINCT attachment_id')).not_to include(un_authored_attachment.id)
      end
    end

    context 'when filtered by keyword' do
      it 'returns all filtered results of user' do
        keyword = 'e'
        attachment = create :attachment, user_id: user.id
        nimble_result = create :result, keyword: 'Nimble', attachment_id: attachment.id
        company_result = create :result, keyword: 'company', attachment_id: attachment.id
        vietnam_result = create :result, keyword: 'VietNam', attachment_id: attachment.id
        un_authored_attachment = create :attachment, user_id: other_user.id

        get :index, params: { q: keyword }
        results = controller.instance_variable_get(:@results)

        expect(response).to have_http_status :success
        expect(results.size).to eq(2)
        expect(results.klass.name).to eq(Result.name)
        expect(results.pluck('DISTINCT keyword')).to include(nimble_result.keyword, vietnam_result.keyword)
        expect(results.pluck('DISTINCT keyword')).not_to include(company_result.keyword)
        expect(results.pluck('DISTINCT attachment_id')).not_to include(un_authored_attachment.id)
      end
    end
  end

  describe 'GET #show' do
    subject { get :show, params: { id: result.id } }

    let(:attachment) { create :attachment, user_id: user.id }
    let(:result) { create :result, attachment_id: attachment.id }
    let(:un_authored_attachment) { create :attachment, user_id: other_user.id }
    let(:un_authored_result) { create :result, attachment_id: un_authored_attachment.id }

    it 'returns result of user' do
      attachment = create :attachment, user_id: user.id
      result = create :result, attachment_id: attachment.id
      params = { id: result.id }

      get :show, params: params

      expect(response).to have_http_status :success
      expect(controller.instance_variable_get(:@result)).to be_a(Result)
      expect(controller.instance_variable_get(:@result)).to eq(result)
    end

    it 'returns nil for un-authored result' do
      un_authored_attachment = create :attachment, user_id: other_user.id
      un_authored_result = create :result, attachment_id: un_authored_attachment.id
      params = { id: un_authored_result.id }

      get :show, params: params

      expect(response).to have_http_status :success
      expect(controller.instance_variable_get(:@result)).to eq(nil)
    end
  end
end
