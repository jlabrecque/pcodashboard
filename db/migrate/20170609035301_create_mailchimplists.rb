class CreateMailchimplists < ActiveRecord::Migration[5.0]
  def self.up
    create_table :mailchimplists do |t|
      t.integer "person_id"
      t.string "email_type"
      t.string "lname"
      t.string "fname"
      t.float "open_rate"
      t.float "click_rate"
      t.string "status"
      t.string "email_client"
      t.string "timezone"
      t.string "country"
      t.float "longitude"
      t.float "latitude"
      t.string "email_address"
      t.string "unique_id"
      t.string "list_id"
      t.datetime "info_changed"
      t.timestamps
    end
  end
  def self.down
    drop_table :mailchimplists
    end
end
