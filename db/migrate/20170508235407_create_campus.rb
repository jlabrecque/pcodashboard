class CreateCampus < ActiveRecord::Migration[5.0]

def self.up
  create_table :campus do |t|
    t.string "campus_id"
    t.string "campus_name"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"

    t.timestamps
  end
end
def self.down
  drop_table :campus
  end
end
