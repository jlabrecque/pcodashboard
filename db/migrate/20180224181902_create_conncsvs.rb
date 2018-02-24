class CreateConncsvs < ActiveRecord::Migration[5.0]
def self.up
  create_table :conncsvs do |t|
    t.string "week_of"
    t.longtext "header"
    t.longtext "cards"
    t.integer "columncount"
    t.integer  "cardcount"
    t.timestamps
  end

end
def self.down
  drop_table :conncsvs
  end
end
