
require "test_helper"

class Api::V1::SalariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:employee_one)
  end

  test "returns salary history in descending effective date order" do
    Salary.create!(
      employee: @employee,
      amount: 90000,
      currency_code: "INR",
      effective_from: Date.new(2026, 1, 1)
    )

    get "/api/v1/employees/#{@employee.id}/salaries"

    assert_response :success

    salaries = response.parsed_body["data"]

    assert_equal 2, salaries.length
    dates = salaries.map { |salary| Date.parse(salary["effective_from"]) }
    assert_equal dates.sort.reverse, dates
  end

  test "creates a salary for an employee" do
    assert_difference("Salary.count", 1) do
      post "/api/v1/employees/#{@employee.id}/salaries", params: {
        salary: {
          amount: 95000,
          currency_code: "INR",
          effective_from: "2026-01-01"
        }
      }
    end

    assert_response :created

    salary = response.parsed_body.dig("data")

    assert_equal "95000.0", salary["amount"]
    assert_equal "INR", salary["currency_code"]
  end

  test "rejects a salary with a non-positive amount" do
    assert_no_difference("Salary.count") do
      post "/api/v1/employees/#{@employee.id}/salaries", params: {
        salary: {
          amount: 0,
          currency_code: "INR",
          effective_from: "2026-01-01"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_not_empty response.parsed_body["errors"]
  end

  test "rejects an invalid currency code" do
    assert_no_difference("Salary.count") do
      post "/api/v1/employees/#{@employee.id}/salaries", params: {
        salary: {
          amount: 95000,
          currency_code: "IN",
          effective_from: "2026-01-01"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_not_empty response.parsed_body["errors"]
  end

  test "rejects an invalid effective date range" do
    assert_no_difference("Salary.count") do
      post "/api/v1/employees/#{@employee.id}/salaries", params: {
        salary: {
          amount: 95000,
          currency_code: "INR",
          effective_from: "2026-12-31",
          effective_to: "2026-01-01"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "rejects an overlapping salary period" do
    assert_no_difference("Salary.count") do
      post "/api/v1/employees/#{@employee.id}/salaries", params: {
        salary: {
          amount: 95000,
          currency_code: "INR",
          effective_from: "2025-06-01",
          effective_to: "2025-12-31"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_not_empty response.parsed_body["errors"]
  end

  test "returns 404 when employee does not exist" do
    get "/api/v1/employees/999999/salaries"

    assert_response :not_found
    assert_equal "Record not found", response.parsed_body["error"]
  end

  test "does not create salary when employee does not exist" do
    assert_no_difference("Salary.count") do
      post "/api/v1/employees/999999/salaries", params: {
        salary: {
          amount: 95000,
          currency_code: "INR",
          effective_from: "2026-01-01"
        }
      }
    end

    assert_response :not_found
  end
end
