class CreateEvents < ActiveRecord::Migration[5.0]
  def self.up
    create_table :events do |t|
      t.string "event_id_pco"
      t.string "event_name"
      t.string "event_updated_at"
      t.string "frequency"
      t.timestamps
    end
  end
  def self.down
    drop_table :events
    end
  end
