require 'rails_helper'

RSpec.describe ResultsController, type: :controller do
  let(:user) { create :user }
  let(:other_user) { create :user }
  before { sign_in user }

  describe 'Filters' do
    it { should use_before_action(:authenticate_user!) }
  end

  describe 'GET #index' do
    subject { get :index }

    let(:number_of_results) { 10 }
    let(:attachment) { create :attachment, user_id: user.id }
    let(:un_authored_attachment) { create :attachment, user_id: other_user.id }

    context 'without params' do
      before { create_list :result, number_of_results, attachment_id: attachment.id }

      it 'returns all results of user' do
        expect(subject).to have_http_status :success
        expect(controller.instance_variable_get(:@results).size).to eq(number_of_results)
        expect(controller.instance_variable_get(:@results).klass.name).to eq(Result.name)
        expect(controller.instance_variable_get(:@results).pluck('DISTINCT attachment_id')).not_to include(un_authored_attachment.id)
      end
    end

    context 'filtered by keyword' do
      subject { get :index, params: { q: keyword } }

      let(:keyword) { 'e' }
      let!(:nimble_result) { create :result, keyword: 'Nimble', attachment_id: attachment.id }
      let!(:company_result) { create :result, keyword: 'company', attachment_id: attachment.id }
      let!(:vietnam_result) { create :result, keyword: 'VietNam', attachment_id: attachment.id }

      it 'returns all filtered results of user' do
        expect(subject).to have_http_status :success
        expect(controller.instance_variable_get(:@results).size).to eq(2)
        expect(controller.instance_variable_get(:@results).klass.name).to eq(Result.name)
        expect(controller.instance_variable_get(:@results).pluck('DISTINCT keyword')).to include(nimble_result.keyword, vietnam_result.keyword)
        expect(controller.instance_variable_get(:@results).pluck('DISTINCT keyword')).not_to include(company_result.keyword)
        expect(controller.instance_variable_get(:@results).pluck('DISTINCT attachment_id')).not_to include(un_authored_attachment.id)
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
      params = { id: result.id }
      get :show, params: params

      expect(response).to have_http_status :success
      expect(controller.instance_variable_get(:@result)).to be_a(Result)
      expect(controller.instance_variable_get(:@result)).to eq(result)
    end

    it 'returns nil for un-authored result' do
      params = { id: un_authored_result.id }
      get :show, params: params

      expect(response).to have_http_status :success
      expect(controller.instance_variable_get(:@result)).to eq(nil)
    end
  end
end
