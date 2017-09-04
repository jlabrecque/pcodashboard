class CreateGroupMemberships < ActiveRecord::Migration[5.0]

  def self.up
    create_table :group_memberships do |t|
      t.integer "group_id"
      t.integer "person_id"
      t.boolean "leader"
      t.string "started"
      t.string "ended"
      t.timestamps
    end
    add_index("group_memberships", ["group_id", "person_id"] )
  end
  def self.down
    drop_table :group_memberships

    end
end
