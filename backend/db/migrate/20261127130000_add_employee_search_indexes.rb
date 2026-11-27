class AddEmployeeSearchIndexes < ActiveRecord::Migration[7.2]
  def change
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    add_index :employees, :first_name,
              using: :gin,
              opclass: { first_name: :gin_trgm_ops },
              name: "index_employees_on_first_name_trigram"

    add_index :employees, :last_name,
              using: :gin,
              opclass: { last_name: :gin_trgm_ops },
              name: "index_employees_on_last_name_trigram"

    add_index :employees, :email,
              using: :gin,
              opclass: { email: :gin_trgm_ops },
              name: "index_employees_on_email_trigram"

    add_index :employees, :employee_number,
              using: :gin,
              opclass: { employee_number: :gin_trgm_ops },
              name: "index_employees_on_employee_number_trigram"
  end
end
