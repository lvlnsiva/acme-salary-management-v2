class MakeEmployeeEmailUniquenessCaseInsensitive < ActiveRecord::Migration[7.2]
  def change
    remove_index :employees, name: "index_employees_on_email"

    add_index :employees,
              "LOWER(email)",
              unique: true,
              name: "index_employees_on_lower_email"
  end
end