# frozen_string_literal: true

module Api
  module V1
    class ResultsController < Api::V1::ApplicationController
      def index
        results = current_user.results.by_keyword(params[:q].to_s)

        render json: results
      end

      def show
        result = current_user.results.find_by(id: params[:id])

        render json: result
      end

      def keywords
        keywords = current_user.results.pluck('DISTINCT keyword')

        render json: keywords
      end
    end
  end
end
