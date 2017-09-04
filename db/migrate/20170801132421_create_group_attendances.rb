class CreateGroupAttendances < ActiveRecord::Migration[5.0]
  def self.up
    create_table :group_attendances do |t|
      t.integer "group_id"
      t.integer "person_id"
      t.string "attend_date"
      t.timestamps
    end
    add_index("group_attendances", ["group_id", "person_id"] )

  end
  def self.down
    drop_table :group_attendances
    end
end
