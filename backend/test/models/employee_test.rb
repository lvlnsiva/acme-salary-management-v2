require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  def valid_employee_attributes
    {
      employee_number: "EMP1001",
      first_name: "Asha",
      last_name: "Rao",
      email: "asha.rao@example.com",
      job_title: "Software Engineer",
      employment_status: "active",
      country: countries(:india),
      department: departments(:engineering)
    }
  end

  test "creates an employee with valid attributes" do
    employee = Employee.new(valid_employee_attributes)

    assert employee.valid?
    assert employee.save
  end

  test "requires employee number" do
    employee = Employee.new(valid_employee_attributes.merge(employee_number: nil))

    assert_not employee.valid?
    assert employee.errors[:employee_number].any?
  end

  test "requires first name, last name and job title" do
    %i[first_name last_name job_title].each do |attribute|
      employee = Employee.new(valid_employee_attributes.merge(attribute => nil))

      assert_not employee.valid?
      assert employee.errors[attribute].any?
    end
  end

  test "requires email" do
    employee = Employee.new(valid_employee_attributes.merge(email: nil))

    assert_not employee.valid?
    assert employee.errors[:email].any?
  end

  test "rejects invalid email formats" do
    invalid_emails = [
      "invalid",
      "user@",
      "@example.com",
      "user name@example.com",
      "user@@example.com",
      "user@example..com",
      "user@.com"
    ]

    invalid_emails.each do |email|
      employee = Employee.new(valid_employee_attributes.merge(email: email))

      assert_not employee.valid?, "Expected #{email.inspect} to be invalid"
      assert employee.errors[:email].any?
    end
  end

  test "requires a unique employee number" do
    existing = employees(:employee_one)
    employee = Employee.new(
      valid_employee_attributes.merge(employee_number: existing.employee_number)
    )

    assert_not employee.valid?
    assert employee.errors[:employee_number].any?
  end

  test "requires a unique email regardless of case" do
    existing = employees(:employee_one)
    employee = Employee.new(
      valid_employee_attributes.merge(email: existing.email.upcase)
    )

    assert_not employee.valid?
    assert employee.errors[:email].any?
  end

  test "accepts active and inactive employment statuses" do
    Employee::EMPLOYMENT_STATUSES.each do |status|
      employee = Employee.new(
        valid_employee_attributes.merge(employment_status: status)
      )

      assert employee.valid?, "Expected #{status.inspect} to be valid"
    end
  end

  test "rejects unsupported employment statuses" do
    employee = Employee.new(
      valid_employee_attributes.merge(employment_status: "terminated")
    )

    assert_not employee.valid?
    assert employee.errors[:employment_status].any?
  end

  test "defaults employment status to active" do
    employee = Employee.new(valid_employee_attributes.except(:employment_status))

    assert_equal "active", employee.employment_status
    assert employee.valid?
  end

  test "requires a country" do
    employee = Employee.new(valid_employee_attributes.merge(country: nil))

    assert_not employee.valid?
    assert employee.errors[:country].any?
  end

  test "requires a department" do
    employee = Employee.new(valid_employee_attributes.merge(department: nil))

    assert_not employee.valid?
    assert employee.errors[:department].any?
  end

  test "belongs to the assigned country and department" do
    employee = employees(:employee_one)

    assert_equal countries(:india), employee.country
    assert_equal departments(:engineering), employee.department
  end

  test "country association returns its employees" do
    employee = employees(:employee_one)

    assert_includes employee.country.employees, employee
  end

  test "department association returns its employees" do
    employee = employees(:employee_one)

    assert_includes employee.department.employees, employee
  end
end