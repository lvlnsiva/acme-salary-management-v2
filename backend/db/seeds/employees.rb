
module AcmeSeeds
  def self.load_employees!
    now = Time.current
    country_ids = Country.pluck(:country_code, :id).to_h
    department_ids = Department.pluck(:name, :id).to_h

    EMPLOYEE_NUMBERS.each_slice(BATCH_SIZE).with_index do |numbers, batch_index|
      employee_rows = numbers.each_with_index.map do |employee_number, index|
        number = batch_index * BATCH_SIZE + index + 1

        country = COUNTRIES[(number - 1) % COUNTRIES.length]
        department = DEPARTMENTS[(number - 1) % DEPARTMENTS.length]
        inactive = (number % 7).zero?

        {
          employee_number: employee_number,
          first_name: FIRST_NAMES[(number - 1) % FIRST_NAMES.length],
          last_name: LAST_NAMES[(number - 1) % LAST_NAMES.length],
          email: "employee.#{number}@acme.example.com",
          job_title: "#{department} Specialist",
          employment_status: inactive ? "inactive" : "active",
          last_working_date: inactive ? Date.new(2025, 1, 1) + (number % 365) : nil,
          country_id: country_ids.fetch(country[:country_code]),
          department_id: department_ids.fetch(department),
          created_at: now,
          updated_at: now
        }
      end

      Employee.insert_all(
        employee_rows,
        unique_by: :index_employees_on_employee_number
      )
    end

    puts "Employee data loaded: #{Employee.count} employees"
  end
end
