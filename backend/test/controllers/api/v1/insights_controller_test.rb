require "test_helper"

class Api::V1::InsightsControllerTest < ActionDispatch::IntegrationTest
  test "returns headcount and currency-separated current salary summaries" do
    get "/api/v1/insights"

    assert_response :success

    data = response.parsed_body.fetch("data")
    assert_equal %w[active inactive total].sort, data.fetch("headcount").keys.sort
    assert data.fetch("headcount").fetch("total") >= 2
    assert_kind_of Array, data.fetch("current_salary")
    assert_kind_of Array, data.fetch("salary_by_currency")
    assert_kind_of Array, data.fetch("salary_by_department")
    assert_kind_of Array, data.fetch("salary_by_country")
  end
end
