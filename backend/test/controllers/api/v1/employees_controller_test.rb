
require "test_helper"

class Api::V1::EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:employee_one)
  end

  test "returns active and inactive employees by default" do
    inactive_employee = Employee.create!(
      employee_number: "EMP0003",
      first_name: "David",
      last_name: "Wilson",
      email: "david.wilson@example.com",
      job_title: "Developer",
      employment_status: "inactive",
      last_working_date: Date.new(2025, 12, 31),
      country: countries(:india),
      department: departments(:engineering)
    )

    get "/api/v1/employees"

    assert_response :success

    ids = response.parsed_body["data"].map { |employee| employee["id"] }

    assert_includes ids, @employee.id
    assert_includes ids, inactive_employee.id
  end

  test "filters employees by employment status" do
    get "/api/v1/employees", params: { employment_status: "inactive" }

    assert_response :success
    assert_empty response.parsed_body["data"]
  end

  test "rejects invalid employment status" do
    get "/api/v1/employees", params: { employment_status: "terminated" }

    assert_response :bad_request
  end

  test "searches employees by name" do
    get "/api/v1/employees", params: { search: "John" }

    assert_response :success

    ids = response.parsed_body["data"].map { |employee| employee["id"] }

    assert_includes ids, @employee.id
  end

  test "filters employees by country" do
    get "/api/v1/employees", params: { country: countries(:india).id }

    assert_response :success

    ids = response.parsed_body["data"].map { |employee| employee["id"] }

    assert_includes ids, @employee.id
  end

  test "filters employees by department" do
    get "/api/v1/employees", params: { department: departments(:engineering).id }

    assert_response :success

    ids = response.parsed_body["data"].map { |employee| employee["id"] }

    assert_includes ids, @employee.id
  end

  test "returns pagination metadata" do
    get "/api/v1/employees", params: { page: 1, per_page: 1 }

    assert_response :success

    meta = response.parsed_body["meta"]

    assert_equal 1, meta["page"]
    assert_equal 1, meta["per_page"]
    assert meta["total_count"] >= 1
    assert meta["total_pages"] >= 1
  end

  test "shows employee details with salary history" do
    get "/api/v1/employees/#{@employee.id}"

    assert_response :success

    body = response.parsed_body

    assert_equal @employee.id, body["id"]
    assert_equal "India", body.dig("country", "name")
    assert_equal "Engineering", body.dig("department", "name")
    assert_equal 1, body["salaries"].length
  end

  test "returns salary history in descending effective date order" do
    Salary.create!(
      employee: @employee,
      amount: 90000,
      currency_code: "INR",
      effective_from: Date.new(2026, 1, 1),
      effective_to: nil
    )

    get "/api/v1/employees/#{@employee.id}"

    assert_response :success

    dates = response.parsed_body["salaries"].map do |salary|
      Date.parse(salary["effective_from"])
    end

    assert_equal dates.sort.reverse, dates
  end

  test "returns 404 when employee does not exist" do
    get "/api/v1/employees/999999"

    assert_response :not_found
    assert_equal "Record not found", response.parsed_body["error"]
  end

  test "creates an employee" do
    assert_difference("Employee.count", 1) do
      post "/api/v1/employees", params: {
        employee: {
          employee_number: "EMP0099",
          first_name: "Alex",
          last_name: "Brown",
          email: "alex.brown@example.com",
          job_title: "Developer",
          employment_status: "active",
          country_id: countries(:india).id,
          department_id: departments(:engineering).id,
          last_working_date: nil
        }
      }
    end

    assert_response :created
    assert_not_nil response.parsed_body["id"]
  end

  test "updates an employee" do
    patch "/api/v1/employees/#{@employee.id}", params: {
      employee: { job_title: "Senior Engineer" }
    }

    assert_response :success
    assert_equal "Senior Engineer", @employee.reload.job_title
  end

  test "deletes an employee without salary history" do
    employee = Employee.create!(
      employee_number: "EMP0100",
      first_name: "Delete",
      last_name: "Candidate",
      email: "delete.candidate@example.com",
      job_title: "Developer",
      employment_status: "active",
      country: countries(:india),
      department: departments(:engineering)
    )

    assert_difference("Employee.count", -1) do
      delete "/api/v1/employees/#{employee.id}"
    end

    assert_response :no_content
  end

  test "does not delete an employee with salary history" do
    assert_no_difference("Employee.count") do
      delete "/api/v1/employees/#{@employee.id}"
    end

    assert_response :unprocessable_entity
  end
end
