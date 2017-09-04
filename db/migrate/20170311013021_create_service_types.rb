class CreateServiceTypes < ActiveRecord::Migration[5.0]

def self.up
  create_table :service_types do |t|
    t.string "stid"
    t.string "st_name"
    t.string "st_updated_at"
    t.string "st_freq"
    t.timestamps
  end
end
def self.down
  drop_table :service_types
  end
end
