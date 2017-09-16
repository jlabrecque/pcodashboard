class CreateWorkflowsteps < ActiveRecord::Migration[5.0]
def self.up
    create_table :workflowsteps do |t|
    t.integer "workflow_id"
    t.string "workflow_id_pco"
    t.string "workflowstep_id_pco"
    t.string "workflowstep_name"
    t.string "workflowstep_default_assignee"
    t.string "workflowstep_sequence"
    t.integer "workflowstep_total_ready_card"
    t.integer "workflowstep_total_snoozed_card"
    t.string "workflowstep_created_at"
    t.string "workflowstep_updated_at"
    t.timestamps
    end
  end
  def self.down
    drop_table :workflowsteps
    end
end
