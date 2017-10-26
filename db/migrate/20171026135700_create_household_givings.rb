class CreateHouseholdGivings < ActiveRecord::Migration[5.0]
    def self.up
      create_table :household_givings do |t|
        t.string  "pco_id"
        t.integer "person_id"
        t.string  "last_name"
        t.string  "first_name"
        t.string  "campus"
        t.string  "family"
        t.text    "month1"
        t.text    "month2"
        t.text    "month3"
        t.text    "month4"
        t.text    "month5"
        t.text    "month6"
        t.text    "month7"
        t.text    "month8"
        t.text    "month9"
        t.text    "month10"
        t.text    "month11"
        t.text    "month12"
        t.float   'annavg'
        t.float   'lastqtravg'
        t.float   'lastmntavg'
        t.timestamps
      end
    end

    def self.down
      drop_table :household_givings
      end

end
