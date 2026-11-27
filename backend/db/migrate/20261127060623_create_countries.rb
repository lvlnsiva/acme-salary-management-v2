class CreateCountries < ActiveRecord::Migration[7.2]
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.string :country_code, null: false, limit: 2

      t.timestamps
    end

    add_index :countries, :country_code, unique: true
  end
end
