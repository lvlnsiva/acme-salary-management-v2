class CreateSalaries < ActiveRecord::Migration[7.2]
  def change
    create_table :salaries do |t|
      t.references :employee, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency_code, limit: 3, null: false
      t.date :effective_from, null: false
      t.date :effective_to

      t.timestamps
    end

    add_index :salaries, [:employee_id, :effective_from]

    add_check_constraint :salaries,
      "amount > 0",
      name: "salaries_amount_positive"

    add_check_constraint :salaries,
      "currency_code ~ '^[A-Z]{3}$'",
      name: "salaries_currency_code_format"

    add_check_constraint :salaries,
      "effective_to IS NULL OR effective_to >= effective_from",
      name: "salaries_valid_effective_dates"
  end
end