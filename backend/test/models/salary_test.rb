require "test_helper"

class SalaryTest < ActiveSupport::TestCase
  def valid_salary_attributes(overrides = {})
    {
      employee: employees(:employee_one),
      amount: BigDecimal("75000.00"),
      currency_code: "INR",
      effective_from: Date.new(2026, 1, 1),
      effective_to: Date.new(2026, 12, 31)
    }.merge(overrides)
  end

  test "creates a salary with valid attributes" do
    salary = Salary.new(valid_salary_attributes)

    assert salary.valid?
    assert salary.save
  end

  test "requires an employee" do
    salary = Salary.new(valid_salary_attributes.merge(employee: nil))

    assert_not salary.valid?
    assert salary.errors[:employee].any?
  end

  test "requires a positive salary amount" do
    [nil, 0, -1, -100.50].each do |amount|
      salary = Salary.new(valid_salary_attributes.merge(amount: amount))

      assert_not salary.valid?, "Expected amount #{amount.inspect} to be invalid"
      assert salary.errors[:amount].any?
    end
  end

  test "accepts a positive decimal salary amount" do
    salary = Salary.new(valid_salary_attributes.merge(amount: 1250.75))

    assert salary.valid?
  end

  test "requires a currency code" do
    salary = Salary.new(valid_salary_attributes.merge(currency_code: nil))

    assert_not salary.valid?
    assert salary.errors[:currency_code].any?
  end

  test "accepts uppercase three-letter currency codes" do
    %w[INR USD EUR GBP].each do |currency_code|
      salary = Salary.new(
        valid_salary_attributes.merge(currency_code: currency_code)
      )

      assert salary.valid?, "Expected #{currency_code.inspect} to be valid"
    end
  end

  test "rejects invalid currency codes" do
    %w[inr Inr US IN USDD 123].each do |currency_code|
      salary = Salary.new(
        valid_salary_attributes.merge(currency_code: currency_code)
      )

      assert_not salary.valid?, "Expected #{currency_code.inspect} to be invalid"
      assert salary.errors[:currency_code].any?
    end
  end

  test "requires an effective start date" do
    salary = Salary.new(
      valid_salary_attributes.merge(effective_from: nil)
    )

    assert_not salary.valid?
    assert salary.errors[:effective_from].any?
  end

  test "allows an ongoing salary without an effective end date" do
    salary = Salary.new(
      valid_salary_attributes.merge(effective_to: nil)
    )

    assert salary.valid?
  end

  test "rejects an end date before the start date" do
    salary = Salary.new(
      valid_salary_attributes.merge(
        effective_from: Date.new(2026, 6, 1),
        effective_to: Date.new(2026, 5, 31)
      )
    )

    assert_not salary.valid?
    assert salary.errors[:effective_to].any?
  end

  test "allows the same start and end date" do
    date = Date.new(2026, 6, 1)
    salary = Salary.new(
      valid_salary_attributes.merge(
        effective_from: date,
        effective_to: date
      )
    )

    assert salary.valid?
  end

  test "rejects a salary period that overlaps an existing period" do
    salary = Salary.new(
      valid_salary_attributes.merge(
        effective_from: Date.new(2025, 6, 1),
        effective_to: Date.new(2025, 12, 31)
      )
    )

    assert_not salary.valid?
    assert salary.errors[:effective_from].any?
  end

  test "rejects a salary period that starts on an existing period's end date" do
    salary = Salary.new(
      valid_salary_attributes.merge(
        effective_from: Date.new(2025, 12, 31),
        effective_to: Date.new(2026, 6, 30)
      )
    )

    assert_not salary.valid?
    assert salary.errors[:effective_from].any?
  end

  test "allows consecutive non-overlapping salary periods" do
    Salary.create!(
      valid_salary_attributes(
        effective_from: Date.new(2026, 1, 1),
        effective_to: Date.new(2026, 6, 30)
      )
    )

    next_salary = Salary.new(
      valid_salary_attributes(
        effective_from: Date.new(2026, 7, 1),
        effective_to: Date.new(2026, 12, 31)
      )
    )

    assert next_salary.valid?
  end

  test "rejects a new salary period overlapping an ongoing salary" do
    ongoing_salary = Salary.create!(
      valid_salary_attributes.merge(effective_to: nil)
    )

    next_salary = Salary.new(
      valid_salary_attributes.merge(
        effective_from: Date.new(2027, 1, 1),
        effective_to: Date.new(2027, 12, 31)
      )
    )

    assert_not next_salary.valid?
    assert next_salary.errors[:effective_from].any?
  end

  test "allows overlapping dates for different employees" do
    Salary.create!(
      valid_salary_attributes(
        effective_from: Date.new(2026, 1, 1),
        effective_to: Date.new(2026, 12, 31)
      )
    )

    salary = Salary.new(
      valid_salary_attributes(
        employee: employees(:employee_two),
        effective_from: Date.new(2026, 6, 1),
        effective_to: Date.new(2026, 12, 31)
      )
    )

    assert salary.valid?
  end

  test "does not treat the salary record itself as an overlapping period" do
    salary = salaries(:salary_one)

    assert salary.valid?
  end

  test "belongs to an employee" do
    assert_equal employees(:employee_one), salaries(:salary_one).employee
  end

  test "employee has many salary records" do
    assert_includes employees(:employee_one).salaries, salaries(:salary_one)
  end
end