
module AcmeSeeds
  def self.load_reference_data!
    now = Time.current

    Country.upsert_all(
      COUNTRIES.map do |country|
        {
          name: country[:name],
          country_code: country[:country_code],
          created_at: now,
          updated_at: now
        }
      end,
      unique_by: :index_countries_on_country_code
    )

    Department.upsert_all(
      DEPARTMENTS.map do |name|
        {
          name: name,
          created_at: now,
          updated_at: now
        }
      end,
      unique_by: :index_departments_on_name
    )

    puts "Reference data loaded: #{Country.count} countries, #{Department.count} departments"
  end
end
