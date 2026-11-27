
module Api
  module V1
    class InsightsController < ApplicationController
      def index
        as_of_date = Date.current

        render json: {
          as_of_date: as_of_date,
          headcount: headcount,
          salary_by_currency: salary_by_currency(as_of_date),
          employees_by_country: employees_by_country,
          employees_by_department: employees_by_department,
          compensation_by_country: compensation_by_country(as_of_date),
          compensation_by_department: compensation_by_department(as_of_date)
        }
      end

      private

      def headcount
        counts = Employee.group(:employment_status).count

        {
          total: counts.values.sum,
          active: counts.fetch("active", 0),
          inactive: counts.fetch("inactive", 0)
        }
      end

      def current_salaries(as_of_date)
        Salary
          .joins(:employee)
          .where(employees: { employment_status: "active" })
          .where(
            "salaries.effective_from <= :date AND " \
            "(salaries.effective_to IS NULL OR salaries.effective_to >= :date)",
            date: as_of_date
          )
      end

      def salary_by_currency(as_of_date)
        current_salaries(as_of_date)
          .group(:currency_code)
          .sum(:amount)
          .map do |currency_code, total_amount|
            {
              currency_code: currency_code,
              total_amount: total_amount.to_s("F")
            }
          end
          .sort_by { |item| item[:currency_code] }
      end

      def employees_by_country
        Employee
          .joins(:country)
          .group("countries.id", "countries.name")
          .count
          .map do |(country_id, country_name), employee_count|
            {
              country_id: country_id,
              country_name: country_name,
              employee_count: employee_count
            }
          end
          .sort_by { |item| item[:country_name] }
      end

      def employees_by_department
        Employee
          .joins(:department)
          .group("departments.id", "departments.name")
          .count
          .map do |(department_id, department_name), employee_count|
            {
              department_id: department_id,
              department_name: department_name,
              employee_count: employee_count
            }
          end
          .sort_by { |item| item[:department_name] }
      end

      def compensation_by_country(as_of_date)
        current_salaries(as_of_date)
          .joins(employee: :country)
          .group(
            "countries.id",
            "countries.name",
            "salaries.currency_code"
          )
          .sum(:amount)
          .map do |(country_id, country_name, currency_code), total_amount|
            {
              country_id: country_id,
              country_name: country_name,
              currency_code: currency_code,
              total_amount: total_amount.to_s("F")
            }
          end
          .sort_by { |item| [item[:country_name], item[:currency_code]] }
      end

      def compensation_by_department(as_of_date)
        current_salaries(as_of_date)
          .joins(employee: :department)
          .group(
            "departments.id",
            "departments.name",
            "salaries.currency_code"
          )
          .sum(:amount)
          .map do |(department_id, department_name, currency_code), total_amount|
            {
              department_id: department_id,
              department_name: department_name,
              currency_code: currency_code,
              total_amount: total_amount.to_s("F")
            }
          end
          .sort_by { |item| [item[:department_name], item[:currency_code]] }
      end
    end
  end
end
