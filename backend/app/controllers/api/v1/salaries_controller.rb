
module Api
  module V1
    class SalariesController < ApplicationController
      def index
        employee = Employee.find(params[:employee_id])

        salaries = employee.salaries.order(effective_from: :desc)

        render json: {
          data: salaries.map { |salary| salary_json(salary) }
        }
      end

      def create
        employee = Employee.find(params[:employee_id])
        salary = nil

        employee.with_lock do
          salary = employee.salaries.new(salary_params)

          unless salary.save
            return render json: { errors: salary.errors.full_messages },
                          status: :unprocessable_entity
          end
        end

        render json: { data: salary_json(salary) }, status: :created
      end

      private

      def salary_params
        params.require(:salary).permit(
          :amount,
          :currency_code,
          :effective_from,
          :effective_to
        )
      end

      def salary_json(salary)
        salary.as_json(
          only: [
            :id,
            :amount,
            :currency_code,
            :effective_from,
            :effective_to
          ]
        )
      end
    end
  end
end
