class CreateGroups < ActiveRecord::Migration[5.0]
  def self.up
    create_table :groups do |t|
      t.string "pco_group_id"
      t.string "description"
      t.string "category"
      t.string "start"
      t.string "end"
      t.boolean "open"
      t.string "group_url"
      t.timestamps
    end

  end
  def self.down
    drop_table :groups
    end
end
