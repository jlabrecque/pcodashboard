class CreatePledges < ActiveRecord::Migration[5.0]
  def self.up
    create_table :pledges do |t|
      t.string "campaign"
      t.string "pledge_date"
      t.string "pco_id"
      t.string "fname"
      t.string "lname"
      t.string "pco_id2"
      t.string "fname2"
      t.string "lname2"
      t.string "family_id"
      t.integer "household_id"
      t.decimal "initial_gift"
      t.decimal "pledge_perperiod"
      t.integer "pledge_periods"
      t.string  "periodicity"
      t.string  "pledge_start"
      t.timestamps
    end
  end
  def self.down
    drop_table :pledges
    end
end
