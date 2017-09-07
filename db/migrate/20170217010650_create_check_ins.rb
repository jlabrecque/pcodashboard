class CreateCheckIns < ActiveRecord::Migration[5.0]
  def self.up
    create_table :check_ins do |t|
      t.integer "eventtime_id"
      t.string  "eventtime_id_pco"
      t.string  "checkin_id_pco"
      t.integer "person_id"
      t.string  "checkin_time"
      t.string  "checkin_updated_at"
      t.string  "checkin_kind"
      t.string  "first_name"
      t.string  "last_name"
      t.string  "pco_id"
      t.string  "location"
      t.timestamps
    end
    add_index("check_ins", "pco_id")
    add_index("check_ins", "eventtime_id")
  end
  def self.down
    drop_table :check_ins
    end
  end
