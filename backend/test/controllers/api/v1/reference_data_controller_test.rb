require "test_helper"

class Api::V1::ReferenceDataControllerTest < ActionDispatch::IntegrationTest
  test "lists countries for employee forms" do
    get "/api/v1/countries"

    assert_response :success
    countries = response.parsed_body.fetch("data")
    assert countries.any?
    assert countries.all? { |country| country.key?("country_code") }
  end

  test "lists departments for employee forms" do
    get "/api/v1/departments"

    assert_response :success
    departments = response.parsed_body.fetch("data")
    assert departments.any?
    assert departments.all? { |department| department.key?("name") }
  end
end
