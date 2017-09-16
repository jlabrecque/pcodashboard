class CreateWorkflowcards < ActiveRecord::Migration[5.0]
    def self.up
      create_table :workflowcards do |t|
      t.integer "workflow_id"
      t.string "workflow_id_pco"
      t.string "workflowcard_id_pco"
      t.string "workflowcard_stage"
      t.string "workflowcard_assignee"
      t.integer "person_id"
      t.string "workflowcard_person_id_pco"
      t.string "workflowcard_completed_at"
      t.string "workflowcard_created_at"
      t.string "workflowcard_updated_at"
      t.timestamps
      end
    end
    def self.down
      drop_table :workflowcards
      end
end
