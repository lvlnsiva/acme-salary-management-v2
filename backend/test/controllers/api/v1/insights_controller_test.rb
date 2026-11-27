
require "test_helper"

class Api::V1::InsightsControllerTest < ActionDispatch::IntegrationTest
  test "returns headcount including active and inactive employees" do
    create_employee(
      employee_number: "TEST001",
      email: "test001@example.com",
      employment_status: "inactive"
    )

    get "/api/v1/insights"

    assert_response :success

    headcount = response.parsed_body["headcount"]

    assert_equal 3, headcount["total"]
    assert_equal 2, headcount["active"]
    assert_equal 1, headcount["inactive"]
  end

  test "returns employee distribution by country and department" do
    create_employee(
      employee_number: "TEST002",
      email: "test002@example.com",
      employment_status: "inactive",
      country: countries(:united_states),
      department: departments(:human_resources)
    )

    get "/api/v1/insights"

    assert_response :success

    body = response.parsed_body

    country_counts = body["employees_by_country"].index_by do |item|
      item["country_name"]
    end

    department_counts = body["employees_by_department"].index_by do |item|
      item["department_name"]
    end

    assert_equal 2, country_counts["India"]["employee_count"]
    assert_equal 1, country_counts["United States"]["employee_count"]

    assert_equal 1, department_counts["Engineering"]["employee_count"]
    assert_equal 2, department_counts["Human Resources"]["employee_count"]
  end

  test "returns current compensation grouped by currency" do
    india_employee = create_employee(
      employee_number: "TEST003",
      email: "test003@example.com"
    )

    us_employee = create_employee(
      employee_number: "TEST004",
      email: "test004@example.com",
      country: countries(:united_states),
      department: departments(:human_resources)
    )

    inactive_employee = create_employee(
      employee_number: "TEST005",
      email: "test005@example.com",
      employment_status: "inactive"
    )

    create_salary(india_employee, 100000, "INR", Date.current - 10)
    create_salary(us_employee, 2000, "USD", Date.current - 10)
    create_salary(inactive_employee, 300000, "INR", Date.current - 10)

    get "/api/v1/insights"

    assert_response :success

    body = response.parsed_body

    salary_totals = body["salary_by_currency"].index_by do |item|
      item["currency_code"]
    end

    assert_equal "100000.0", salary_totals["INR"]["total_amount"]
    assert_equal "2000.0", salary_totals["USD"]["total_amount"]

    assert_equal 2, body["salary_by_currency"].length
  end

  test "excludes future salaries from current compensation" do
    employee = create_employee(
      employee_number: "TEST006",
      email: "test006@example.com"
    )

    create_salary(employee, 150000, "INR", Date.current + 10)

    get "/api/v1/insights"

    assert_response :success

    body = response.parsed_body

    assert_empty body["salary_by_currency"]
    assert_empty body["compensation_by_country"]
    assert_empty body["compensation_by_department"]
  end

  test "returns compensation grouped by country and department without combining currencies" do
    india_employee = create_employee(
      employee_number: "TEST007",
      email: "test007@example.com"
    )

    us_employee = create_employee(
      employee_number: "TEST008",
      email: "test008@example.com",
      country: countries(:united_states),
      department: departments(:human_resources)
    )

    create_salary(india_employee, 100000, "INR", Date.current - 10)
    create_salary(us_employee, 2000, "USD", Date.current - 10)

    get "/api/v1/insights"

    assert_response :success

    body = response.parsed_body

    country_compensation = body["compensation_by_country"]
    department_compensation = body["compensation_by_department"]

    assert_equal 2, country_compensation.length
    assert_equal 2, department_compensation.length

    india = country_compensation.find do |item|
      item["country_name"] == "India"
    end

    us = country_compensation.find do |item|
      item["country_name"] == "United States"
    end

    assert_equal "INR", india["currency_code"]
    assert_equal "100000.0", india["total_amount"]

    assert_equal "USD", us["currency_code"]
    assert_equal "2000.0", us["total_amount"]
  end

  test "returns the date used for current compensation calculations" do
    get "/api/v1/insights"

    assert_response :success
    assert_equal Date.current.to_s, response.parsed_body["as_of_date"]
  end

  private

  def create_employee(
    employee_number:,
    email:,
    employment_status: "active",
    country: countries(:india),
    department: departments(:engineering)
  )
    Employee.create!(
      employee_number: employee_number,
      first_name: "Test",
      last_name: "Employee",
      email: email,
      job_title: "Software Engineer",
      employment_status: employment_status,
      country: country,
      department: department
    )
  end

  def create_salary(employee, amount, currency_code, effective_from)
    Salary.create!(
      employee: employee,
      amount: amount,
      currency_code: currency_code,
      effective_from: effective_from,
      effective_to: nil
    )
  end
end
