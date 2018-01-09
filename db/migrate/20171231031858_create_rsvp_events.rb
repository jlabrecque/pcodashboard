class CreateRsvpEvents < ActiveRecord::Migration[5.0]
    def self.up
    create_table :rsvp_events do |t|
      t.string   "name"
      t.integer  "peoplelist_id" #each event tied to a single Plist for invites/status
      t.string   "sdate" #string date
      t.string   "stime" #string time
      t.datetime "date" #actual date/time
      t.longtext "description"
      t.string   "info_url"
      t.integer  "creator"
      t.boolean  "status"
      t.timestamps
    end

  end
  def self.down
    drop_table :rsvp_events
    end
end
