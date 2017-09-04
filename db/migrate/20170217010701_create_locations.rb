class CreateLocations < ActiveRecord::Migration[5.0]
  def self.up
    create_table :locations do |t|
      t.integer "location_id"
      t.string "location_name"
      t.timestamps
    end
  end
  def self.down
    drop_table :locations
    end
  end
