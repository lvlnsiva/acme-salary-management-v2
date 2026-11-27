
module AcmeSeeds
  def self.load_salaries!
    now = Time.current

    employee_ids = Employee
      .where(employee_number: EMPLOYEE_NUMBERS)
      .pluck(:employee_number, :id)
      .to_h

    EMPLOYEE_NUMBERS.each_slice(BATCH_SIZE) do |employee_numbers|
      salary_rows = employee_numbers.flat_map do |employee_number|
        number = employee_number.delete_prefix("ACME").to_i
        country = COUNTRIES[(number - 1) % COUNTRIES.length]

        current_amount = 50_000 + (number % 20) * 2_500
        employee_id = employee_ids.fetch(employee_number)

        rows = [
          {
            employee_id: employee_id,
            amount: current_amount,
            currency_code: country[:currency_code],
            effective_from: Date.new(2026, 1, 1),
            effective_to: nil,
            created_at: now,
            updated_at: now
          }
        ]

        if number <= HISTORICAL_SALARY_COUNT
          rows << {
            employee_id: employee_id,
            amount: (current_amount * 0.9).round(2),
            currency_code: country[:currency_code],
            effective_from: Date.new(2025, 1, 1),
            effective_to: Date.new(2025, 12, 31),
            created_at: now,
            updated_at: now
          }
        end

        rows
      end

      Salary.insert_all(
        salary_rows,
        unique_by: :index_salaries_on_employee_id_and_effective_from
      )
    end

    puts "Salary data loaded: #{Salary.count} salary records"
  end
end
