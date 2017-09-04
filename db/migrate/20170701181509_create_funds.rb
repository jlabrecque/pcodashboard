class CreateFunds < ActiveRecord::Migration[5.0]
  def self.up
  create_table :funds do |t|
    t.string "fund_id"
    t.string "name"
    t.string "description"
    t.string "fund_updated_at"
    t.timestamps
  end
end
def self.down
  drop_table :funds
  end
end
