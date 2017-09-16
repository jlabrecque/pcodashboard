class CreateWorkflows < ActiveRecord::Migration[5.0]
  def self.up
    create_table :workflows do |t|
    t.string "workflow_id_pco"
    t.string "workflow_name"
    t.integer "workflow_completed_cards"
    t.integer "workflow_ready_cards"
    t.string "workflow_created_at"
    t.string "workflow_updated_at"
    t.timestamps
    end
  end
  def self.down
    drop_table :workflows
    end
end
