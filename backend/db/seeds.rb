# Deterministic demo data for local development and assessment review.
# Re-running this file replaces only records whose employee_number starts with DEMO-.
countries = [
  ["India", "IN"], ["United States", "US"], ["United Kingdom", "GB"],
  ["Canada", "CA"], ["Australia", "AU"], ["Germany", "DE"],
  ["Singapore", "SG"], ["United Arab Emirates", "AE"]
].map do |name, code|
  Country.find_or_create_by!(country_code: code) { |country| country.name = name }
end

departments = ["Engineering", "Product", "Human Resources", "Finance", "Sales", "Operations", "Customer Support"].map do |name|
  Department.find_or_create_by!(name: name)
end

demo_employee_ids = Employee.where("employee_number LIKE ?", "DEMO-%").pluck(:id)
Salary.where(employee_id: demo_employee_ids).delete_all if demo_employee_ids.any?
Employee.where(id: demo_employee_ids).delete_all if demo_employee_ids.any?

first_names = %w[Aarav Aditi Akash Ananya Arjun Diya Isha Karan Kavya Neha Rahul Riya Sahana Vikram Zoe Liam Emma Noah Olivia Ethan Ava]
last_names = %w[Sharma Patel Kumar Reddy Gupta Singh Brown Wilson Taylor Martin Anderson Thomas Lee Clark Lewis Walker Hall Young]
titles = ["Software Engineer", "Senior Software Engineer", "Engineering Manager", "Product Manager", "HR Specialist", "Financial Analyst", "Sales Manager", "Support Engineer"]
currency_by_country = {
  "IN" => "INR", "US" => "USD", "GB" => "GBP", "CA" => "CAD",
  "AU" => "AUD", "DE" => "EUR", "SG" => "SGD", "AE" => "AED"
}

now = Time.current
employees = Array.new(10_000) do |index|
  country = countries[index % countries.length]
  active = index % 5 != 0
  last_working_date = active ? nil : Date.new(2025, 1, 1) + (index % 600)
  {
    employee_number: format("DEMO-%05d", index + 1),
    first_name: first_names[index % first_names.length],
    last_name: last_names[(index * 7) % last_names.length],
    email: format("demo.employee.%05d@acme-example.test", index + 1),
    job_title: titles[(index * 3) % titles.length],
    employment_status: active ? "active" : "inactive",
    last_working_date: last_working_date,
    country_id: country.id,
    department_id: departments[(index * 5) % departments.length].id,
    created_at: now,
    updated_at: now
  }
end

employees.each_slice(1_000) { |batch| Employee.insert_all!(batch) }

employee_rows = Employee.where("employee_number LIKE ?", "DEMO-%").pluck(:id, :employee_number, :employment_status, :last_working_date, :country_id)
country_codes = Country.where(id: countries.map(&:id)).pluck(:id, :country_code).to_h
salary_rows = []

employee_rows.each do |id, employee_number, status, last_working_date, country_id|
  sequence = employee_number.delete_prefix("DEMO-").to_i
  next if sequence % 7 == 0

  currency = currency_by_country.fetch(country_codes.fetch(country_id))
  base_amount = 35_000 + ((sequence * 137) % 90_000)
  salary_rows << {
    employee_id: id, amount: base_amount, currency_code: currency,
    effective_from: Date.new(2023, 1, 1), effective_to: Date.new(2023, 12, 31),
    created_at: now, updated_at: now
  }

  current_start = Date.new(2024, 1, 1)
  current_end = status == "active" ? nil : [last_working_date, current_start].max
  next if current_end && current_end < current_start

  salary_rows << {
    employee_id: id,
    amount: (base_amount * (1.05 + (sequence % 15) / 100.0)).round(2),
    currency_code: currency, effective_from: current_start, effective_to: current_end,
    created_at: now, updated_at: now
  }
end

salary_rows.each_slice(2_000) { |batch| Salary.insert_all!(batch) }

puts "Seeded #{employees.size} demo employees and #{salary_rows.size} salary records."
