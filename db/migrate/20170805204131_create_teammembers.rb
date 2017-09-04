class CreateTeammembers < ActiveRecord::Migration[5.0]

  def self.up
    create_table :teammembers do |t|
      t.integer "plan_id"
      t.string "plid"
      t.string "plan_dates"
      t.string "plan_sort_date"
      t.string "tmid"
      t.string "pco_id"
      t.integer "person_id"
      t.string "name"
      t.string "position"
      t.string "status"
      t.string "decline_reason"
      t.string "planperson"
      t.string "plan_updated_at"
      t.timestamps
    end
    add_index("teammembers", "plan_id")
    add_index("teammembers", "person_id")
  end
  def self.down
    drop_table :teammembers
    end


end
