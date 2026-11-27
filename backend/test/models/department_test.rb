require "test_helper"

class DepartmentTest < ActiveSupport::TestCase
  test "requires a name" do
    department = Department.new

    assert_not department.valid?
    assert_includes department.errors[:name], "can't be blank"
  end

  test "requires a unique name" do
    Department.create!(name: "Finance")
    duplicate = Department.new(name: "Finance")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "accepts a valid department" do
    department = Department.new(name: "Finance")

    assert department.valid?
  end
end