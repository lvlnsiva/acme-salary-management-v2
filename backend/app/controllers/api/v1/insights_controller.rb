module Api
  module V1
    class InsightsController < ApplicationController
      def index
        today = Date.current
        current_salaries = Salary
          .where("salaries.effective_from <= ?", today)
          .where("salaries.effective_to IS NULL OR salaries.effective_to >= ?", today)

        render json: {
          data: {
            headcount: {
              total: Employee.count,
              active: Employee.where(employment_status: "active").count,
              inactive: Employee.where(employment_status: "inactive").count
            },
            current_salary: salary_summary(current_salaries),
            salary_by_currency: current_salaries
              .group(:currency_code)
              .order(:currency_code)
              .count
              .map { |currency, count| { currency_code: currency, employee_count: count } },
            salary_by_department: grouped_salary_summary(current_salaries, "departments"),
            salary_by_country: grouped_salary_summary(current_salaries, "countries")
          }
        }
      end

      private

      def salary_summary(scope)
        scope.group(:currency_code).order(:currency_code).count.map do |currency, count|
          values = scope.where(currency_code: currency)
          {
            currency_code: currency,
            employee_count: count,
            average_amount: values.average(:amount)&.round(2),
            total_amount: values.sum(:amount).round(2)
          }
        end
      end

      def grouped_salary_summary(scope, association)
        table = association == "departments" ? Department.arel_table : Country.arel_table
        employee_association = association == "departments" ? :department : :country
        scope
          .joins(employee: employee_association)
          .group(table[:id], table[:name], :currency_code)
          .order(table[:name], :currency_code)
          .pluck(table[:id], table[:name], :currency_code, Arel.sql("COUNT(salaries.id)"), Arel.sql("AVG(salaries.amount)"))
          .map do |id, name, currency, count, average|
            {
              id: id,
              name: name,
              currency_code: currency,
              employee_count: count,
              average_amount: average.to_d.round(2)
            }
          end
      end
    end
  end
end
