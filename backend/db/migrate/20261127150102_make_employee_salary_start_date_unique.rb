class MakeEmployeeSalaryStartDateUnique < ActiveRecord::Migration[7.2]
  def change
    remove_index :salaries, name: "index_salaries_on_employee_id_and_effective_from"

    add_index :salaries,
              [:employee_id, :effective_from],
              unique: true,
              name: "index_salaries_on_employee_id_and_effective_from"
  end
end