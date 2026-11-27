
require_relative "seeds/support"
require_relative "seeds/reference_data"
require_relative "seeds/employees"
require_relative "seeds/salaries"

AcmeSeeds.load_reference_data!

if AcmeSeeds.demo_data_enabled?
  ActiveRecord::Base.transaction do
    AcmeSeeds.load_employees!
    AcmeSeeds.load_salaries!
  end
else
  puts "Demo employee and salary data skipped for #{Rails.env}."
  puts "Set SEED_DEMO_DATA=true to explicitly enable demo data."
end

puts "Seed process completed."
