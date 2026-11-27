
require "test_helper"
require_relative "../../db/seeds/support"

class AcmeSeedsTest < ActiveSupport::TestCase
  test "enables demo data in development" do
    environment = ActiveSupport::StringInquirer.new("development")

    assert AcmeSeeds.demo_data_enabled?(environment: environment, enabled: nil)
  end

  test "enables demo data in test" do
    environment = ActiveSupport::StringInquirer.new("test")

    assert AcmeSeeds.demo_data_enabled?(environment: environment, enabled: nil)
  end

  test "does not enable demo data in production by default" do
    environment = ActiveSupport::StringInquirer.new("production")

    refute AcmeSeeds.demo_data_enabled?(environment: environment, enabled: nil)
  end

  test "enables demo data in production when explicitly requested" do
    environment = ActiveSupport::StringInquirer.new("production")

    assert AcmeSeeds.demo_data_enabled?(environment: environment, enabled: "true")
  end

  test "does not enable demo data for other environment variable values" do
    environment = ActiveSupport::StringInquirer.new("production")

    refute AcmeSeeds.demo_data_enabled?(environment: environment, enabled: "false")
    refute AcmeSeeds.demo_data_enabled?(environment: environment, enabled: "1")
  end
end
