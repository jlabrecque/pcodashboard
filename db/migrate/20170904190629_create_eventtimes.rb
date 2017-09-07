class CreateEventtimes < ActiveRecord::Migration[5.0]
  def self.up
    create_table :eventtimes do |t|
    t.integer "event_id"
    t.string  "event_id_pco"
    t.string  "eventtime_id_pco"
    t.string  "starts_at"
    t.integer "guest_count"
    t.integer "regular_count"
    t.integer "volunteer_count"
    t.timestamps
    end
    add_index("eventtimes", "event_id")
  end
  def self.down
    drop_table :eventtimes
    end
end
