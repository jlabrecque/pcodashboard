class CreateHouseholds < ActiveRecord::Migration[5.0]
    def self.up
      create_table :households do |t|
        t.string  "household_id_pco"
        t.string  "household_name"
        t.string  "household_primary_pco"
        t.integer "person_id"   #Primary Person id
        t.integer "campus_id"
        t.timestamps
      end
    end

    def self.down
      drop_table :households
    end
end
