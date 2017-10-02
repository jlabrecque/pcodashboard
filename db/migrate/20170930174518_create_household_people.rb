  class CreateHouseholdPeople < ActiveRecord::Migration[5.0]
    def self.up
        create_table :household_people do |t|
          t.integer  "person_id"
          t.integer  "household_id"
          t.timestamps
        end

      end

      def self.down
        drop_table :household_people
      end
  end
