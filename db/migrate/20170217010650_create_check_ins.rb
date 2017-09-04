class CreateCheckIns < ActiveRecord::Migration[5.0]
  def self.up
    create_table :check_ins do |t|
      t.string "checkin_id"
      t.integer "person_id"
      t.string "checkin_time"
      t.string "checkin_kind"
      t.string "first_name"
      t.string "last_name"
      t.string "pco_id"
      t.string "event"
      t.string "location"
      t.timestamps
    end
    add_index("check_ins", "pco_id")
  end
  def self.down
    drop_table :check_ins
    end
  end
