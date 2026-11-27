class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.string :employee_number, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :job_title, null: false
      t.string :employment_status, null: false, default: "active"

      t.references :country, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end

    add_index :employees, :employee_number, unique: true
    add_index :employees, :email, unique: true
    add_index :employees, :employment_status
    add_index :employees, [:country_id, :department_id]
  end
end
