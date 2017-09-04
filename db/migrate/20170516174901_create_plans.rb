class CreatePlans < ActiveRecord::Migration[5.0]

  def self.up
    create_table :plans do |t|
      t.string "plid"
      t.string "stid"
      t.string "pldates"
      t.string "pl_sort_date"
      t.string "pl_updated_at"
      t.integer "service_type_id"
      t.timestamps
    end
    add_index("plans", "service_type_id")
  end
  def self.down
    drop_table :plans
    end
end
