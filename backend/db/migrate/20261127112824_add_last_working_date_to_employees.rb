class AddLastWorkingDateToEmployees < ActiveRecord::Migration[7.2]
  def change
    add_column :employees, :last_working_date, :date
  end
end
