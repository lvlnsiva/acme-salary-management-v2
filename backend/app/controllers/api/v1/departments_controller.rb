module Api
  module V1
    class DepartmentsController < ApplicationController
      def index
        render json: {
          data: Department.order(:name).as_json(only: [:id, :name])
        }
      end
    end
  end
end
