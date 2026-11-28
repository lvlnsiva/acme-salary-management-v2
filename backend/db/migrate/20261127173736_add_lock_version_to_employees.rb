class AddLockVersionToEmployees < ActiveRecord::Migration[7.2]
  def change
    add_column :employees, :lock_version, :integer
  end
end
