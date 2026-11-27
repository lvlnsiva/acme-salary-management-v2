
module Api
  module V1
    class EmployeesController < ApplicationController
      def index
        employees = Employee.all

        status = params[:employment_status].presence || "active"
        unless Employee::EMPLOYMENT_STATUSES.include?(status)
          return render json: { error: "Invalid employment status" },
                        status: :bad_request
        end
        employees = employees.where(employment_status: status)

        if params[:search].present?
          search = "%#{params[:search].strip}%"

          employees = employees.where(
            "first_name ILIKE :search OR last_name ILIKE :search OR email ILIKE :search OR employee_number ILIKE :search",
            search: search
          )
        end

        employees = employees.where(country_id: params[:country]) if params[:country].present?
        employees = employees.where(department_id: params[:department]) if params[:department].present?

        page = pagination_value(:page, 1, minimum: 1)
        per_page = pagination_value(:per_page, 20, minimum: 1, maximum: 100)

        total_count = employees.count

        employees = employees
          .includes(:country, :department)
          .order(:id)
          .limit(per_page)
          .offset((page - 1) * per_page)

        render json: {
          data: employees.map { |employee| employee_json(employee) },
          meta: {
            page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: (total_count.to_f / per_page).ceil
          }
        }
      end

      def show
        employee = Employee
          .includes(:country, :department, :salaries)
          .find(params[:id])

        render json: employee_json(employee, include_salaries: true)
      end

      def create
        employee = Employee.new(employee_params)

        if employee.save
          render json: employee_json(employee), status: :created
        else
          render json: { errors: employee.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def update
        employee = Employee.find(params[:id])

        if employee.update(employee_params)
          render json: employee_json(employee)
        else
          render json: { errors: employee.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def destroy
        employee = Employee.find(params[:id])

        if employee.destroy
          head :no_content
        else
          render json: { errors: employee.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def employee_params
        params.require(:employee).permit(
          :employee_number,
          :first_name,
          :last_name,
          :email,
          :country_id,
          :department_id,
          :job_title,
          :employment_status,
          :last_working_date
        )
      end

      def employee_json(employee, include_salaries: false)
        attributes = employee.as_json(
          only: [
            :id,
            :employee_number,
            :first_name,
            :last_name,
            :email,
            :job_title,
            :employment_status,
            :country_id,
            :department_id,
            :created_at,
            :updated_at
          ],
          include: {
            country: { only: [:id, :name, :country_code] },
            department: { only: [:id, :name] }
          }
        )

        if include_salaries
          attributes["salaries"] = employee.salaries.order(effective_from: :desc).map do |salary|
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

        attributes
      end

      def pagination_value(parameter, default, minimum:, maximum: nil)
        value = Integer(params.fetch(parameter, default), 10)
        value = [value, minimum].max
        maximum ? [value, maximum].min : value
      rescue ArgumentError, TypeError
        default
      end
    end
  end
end
