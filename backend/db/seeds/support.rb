
module AcmeSeeds
  BATCH_SIZE = 1_000
  EMPLOYEE_COUNT = 10_000
  HISTORICAL_SALARY_COUNT = 5_000

  def self.demo_data_enabled?(environment: Rails.env, enabled: ENV["SEED_DEMO_DATA"])
    environment.development? ||
      environment.test? ||
      enabled == "true"
  end

  COUNTRIES = [
    { name: "India", country_code: "IN", currency_code: "INR" },
    { name: "United States", country_code: "US", currency_code: "USD" },
    { name: "United Kingdom", country_code: "GB", currency_code: "GBP" },
    { name: "Canada", country_code: "CA", currency_code: "CAD" },
    { name: "Germany", country_code: "DE", currency_code: "EUR" },
    { name: "Australia", country_code: "AU", currency_code: "AUD" }
  ].freeze

  DEPARTMENTS = [
    "Engineering",
    "Human Resources",
    "Finance",
    "Sales",
    "Marketing",
    "Operations",
    "Customer Support",
    "Product"
  ].freeze

  FIRST_NAMES = %w[
    Aarav Aditi Arjun Diya Ishaan Kavya
    Liam Emma Noah Olivia Ethan Sophia
    Oliver Amelia George Isla Lucas Ava
  ].freeze

  LAST_NAMES = %w[
    Sharma Patel Kumar Singh Reddy Gupta
    Smith Johnson Brown Taylor Wilson Davis
    Martin Clark Lewis Walker Hall
  ].freeze

  EMPLOYEE_NUMBERS = (1..EMPLOYEE_COUNT).map do |number|
    format("ACME%05d", number)
  end.freeze
end
