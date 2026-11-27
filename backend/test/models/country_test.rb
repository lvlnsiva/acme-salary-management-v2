require "test_helper"

class CountryTest < ActiveSupport::TestCase
  test "requires a name" do
    country = Country.new(country_code: "JP")

    assert_not country.valid?
    assert_includes country.errors[:name], "can't be blank"
  end

  test "requires a country code" do
    country = Country.new(name: "Japan")

    assert_not country.valid?
    assert_includes country.errors[:country_code], "can't be blank"
  end

  test "accepts a valid two-letter uppercase country code" do
    country = Country.new(name: "Japan", country_code: "JP")

    assert country.valid?
  end

  test "rejects an invalid country code" do
    country = Country.new(name: "Japan", country_code: "JPN")

    assert_not country.valid?
    assert country.errors[:country_code].any?
  end

  test "requires a unique country code" do
    Country.create!(name: "Japan", country_code: "JP")
    duplicate = Country.new(name: "Another Country", country_code: "JP")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:country_code], "has already been taken"
  end
end